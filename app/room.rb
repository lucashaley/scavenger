module HuskGame

  # rubocop:disable Metrics/ClassLength
  class Room
    include Zif::Traceable
    include HuskEngine::Stateable

    attr_reader :name,
                :husk,
                :chaos,
                :threat,
                :entrance_side,
                :tiles_target,
                :tile_dimensions,
                :scale,
                :node
    # Collection arrays — RoomPopulator appends to these via << but never reassigns them
    attr_reader :doors,
                :doors_bits,
                :doors_hash,
                :no_populate_buffer,
                :hazards,
                :spawners,
                :pickups,
                :terminals,
                :agents,
                :dressings,
                :decorations,
                :overlays

    DOORS = {
      none: 0,
      north: 1,
      east: 2,
      south: 4,
      west: 8
    }.freeze
    # rubocop:disable Metrics/MethodLength
    def initialize(
      name: 'entrance',
      husk: nil,
      chaos: 0,
      threat: 0,
      scale: :large,
      node: nil,
      entrance_side: nil
    )
      @tracer_service_name = :tracer

      @name = name
      @husk = husk
      @chaos = chaos
      @threat = threat
      @scale = scale
      @node = node
      @entrance_side = entrance_side
      pixel_scale = HuskGame::Constants::SPRITE_SCALES[@scale]
      @tile_dimensions = HuskGame::Constants::VIEWSCREEN_SIZE.div(pixel_scale)
      @tiles_target = Zif::RenderTarget.new(@name, width: HuskGame::Constants::VIEWSCREEN_SIZE, height: HuskGame::Constants::VIEWSCREEN_SIZE)
      @doors = []
      @hazards = []
      @spawners = []
      @pickups = []
      @terminals = []
      @agents = []
      @dressings = []
      @decorations = []
      @overlays = []
      @doors_hash = {
        north: nil,
        south: nil,
        east: nil,
        west: nil
      }

      @no_populate_buffer = []

      create_tiles

      if @node && @node[:is_breach]
        breach = Breach.new
        @terminals << breach
        @no_populate_buffer << breach.buffer
        @husk.breach = breach
      end

      RoomPopulator.new(self).populate
    end
    # rubocop:enable Metrics/MethodLength

    def renders
      @cached_renders ||= (@pickups + @hazards + @terminals).reject(&:is_dead?)
    end

    def renders_under_player
      @cached_renders_under ||= @decorations + (@pickups + @hazards).reject(&:is_dead?) + @terminals + @dressings + @spawners
    end

    def renders_over_player
      @cached_renders_over ||= @walls + @agents.reject(&:is_dead?)
    end

    def collidables
      @cached_collidables ||= @walls + (@pickups + @hazards + @agents).reject(&:is_dead?) + @terminals + @dressings
    end

    def invalidate_caches
      @cached_renders = nil
      @cached_renders_under = nil
      @cached_renders_over = nil
      @cached_collidables = nil
    end

    # Get collidables near a specific object using spatial partitioning
    def collidables_near(obj)
      spatial_grid = $game && $game.services[:spatial_grid]
      return collidables unless spatial_grid

      spatial_grid.get_nearby(obj)
    end

    # Rebuild the spatial grid for collision optimization
    def rebuild_spatial_grid
      spatial_grid = $game && $game.services[:spatial_grid]
      return unless spatial_grid

      spatial_grid.rebuild(collidables)
    end

    def activate
      @doors.each(&:activate)
      @pickups.each(&:activate)
      @terminals.each(&:activate)
      @hazards.each(&:activate)
      @spawners.each(&:activate)
      @agents.each(&:activate)
      @dressings.each(&:activate)
      @hazards.each { |h| h.activate_effect if h.is_a?(HuskEngine::Effectable) }
      invalidate_caches
      rebuild_spatial_grid
    end

    def deactivate
      @doors.each(&:deactivate)
      @pickups.each(&:deactivate)
      @terminals.each(&:deactivate)
      @hazards.each(&:deactivate)
      @agents.each(&:deactivate)
      @dressings.each(&:deactivate)
      @hazards.each { |h| h.deactivate_effect if h.is_a?(HuskEngine::Effectable) }
      spatial_grid = $game && $game.services[:spatial_grid]
      spatial_grid.reset_grid if spatial_grid
    end

    def purge_deads
      old_pickup_count = @pickups.length
      old_hazard_count = @hazards.length
      old_agent_count = @agents.length
      @pickups.reject!(&:is_dead?)
      @hazards.reject!(&:is_dead?)
      @agents.reject!(&:is_dead?)
      invalidate_caches if @pickups.length != old_pickup_count ||
                           @hazards.length != old_hazard_count ||
                           @agents.length != old_agent_count
    end

    def serialize
      {
        name: @name
        # room_dimensions: @tile_dimensions,
        # doors: @doors,
        # chaos: @chaos
        # tiles: @tiles,
        # pickups: @pickups
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def create_tiles
      viewscreen_offset_x = HuskGame::Constants::VIEWSCREEN_OFFSET_X
      viewscreen_offset_y = HuskGame::Constants::VIEWSCREEN_OFFSET_Y
      pixel_scale = HuskGame::Constants::SPRITE_SCALES[@scale]

      @walls = []
      @tile_dimensions.times do |x|
        @tile_dimensions.times do |y|
          create_tile_at(x, y, pixel_scale, viewscreen_offset_x, viewscreen_offset_y)
        end
      end

      validate_tiles_target
    end

    private

    def create_tile_at(x, y, pixel_scale, offset_x, offset_y)
      facing = determine_wall_facing(x, y)

      if facing
        create_wall_tile(x, y, pixel_scale, offset_x, offset_y, facing)
      else
        create_floor_tile(x, y, pixel_scale)
      end
    end

    def determine_wall_facing(x, y)
      max_index = @tile_dimensions - 1

      # South row
      return :southwest if y.zero? && x.zero?
      return :southeast if y.zero? && x == max_index
      return :south if y.zero?

      # North row
      return :northwest if y == max_index && x.zero?
      return :northeast if y == max_index && x == max_index
      return :north if y == max_index

      # West/East edges
      return :west if x.zero?
      return :east if x == max_index

      nil # Interior tile (floor)
    end

    def create_wall_tile(x, y, pixel_scale, offset_x, offset_y, facing)
      @walls << Wall.new(
        x: (x * pixel_scale) + offset_x,
        y: (y * pixel_scale) + offset_y,
        facing: facing,
        scale: @scale
      )
    end

    def create_floor_tile(x, y, pixel_scale)
      @tiles_target.sprites << Zif::Sprite.new.tap do |s|
        s.x = x * pixel_scale
        s.y = y * pixel_scale
        s.w = pixel_scale
        s.h = pixel_scale
        s.angle = rand(4) * 90
        s.path = HuskGame::AssetPaths::Sprites.floor_sprite(@scale.to_s, rand(6))
      end
    end

    def validate_tiles_target
      raise ArgumentError, "No containing sprite" if @tiles_target.containing_sprite.nil?
    end

    public
  end
end