module HuskGame

  # rubocop:disable Metrics/ClassLength
  class Room
    include Zif::Traceable
    include HuskEngine::Stateable

    attr_accessor :name,
                  :husk,
                  :chaos,
                  :entrance_door,
                  :tiles_target,
                  :tile_dimensions,
                  :scale,
                  :doors,
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
    HAZARD_ODDS = {
      large: {
        chance: 1,
        in: 6
      },
      medium: {
        chance: 2,
        in: 5
      },
      small: {
        chance: 3,
        in: 6
      }
    }.freeze

    # rubocop:disable Metrics/MethodLength
    def initialize(
      name: 'entrance',
      husk: nil,
      chaos: 0,
      scale: :large,
      entrance_door: nil
    )
      @tracer_service_name = :tracer
      # mark_and_print("initialize")

      # Set variables
      @name = name
      @husk = husk
      @chaos = chaos
      @scale = scale
      @entrance_door = entrance_door
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

      if @entrance_door.nil?
        # Presumably we're in the entrypoint?
        breach = Breach.new
        @terminals << breach
        @no_populate_buffer << breach.buffer
        @husk.breach = breach
      end

      unless @entrance_door.nil?
        @doors_hash[@entrance_door.door_side] = @entrance_door
        @doors << @entrance_door
        @no_populate_buffer << @entrance_door.buffer
      end

      populate_doors
      populate_terminals
      populate_pickups
      populate_hazards
      populate_spawners
      # populate_terminals
      populate_agents
      populate_dressings
      populate_decorations
      populate_overlays

      # This is dumping to args for Palantir
      # $gtk.args.state.rooms[@name] = { doors: @doors }

      # puts "\n\nnew room doors: #{@doors}\n\n"
      # initialize_stateable(:rooms)
    end
    # rubocop:enable Metrics/MethodLength

    def populate_doors
      # mark_and_print ("populate_doors")
      @doors_hash.each do |key, value|
        # there are no doors on this side yet
        next unless value.nil? && rand(3) + 1 > @chaos
        # Let's make a new door
        new_door = Door.new(
          scale: @scale,
          door_side: key.to_sym,
          room: self
        )
        @doors_hash[key] = new_door
        @doors << new_door
        @no_populate_buffer << new_door.buffer
      end

      # Ensure entrypoint always has at least one unlocked door
      ensure_unlocked_door if @entrance_door.nil?
    end

    def ensure_unlocked_door
      new_doors = @doors.select { |d| d != @entrance_door }
      return if new_doors.empty?
      return if new_doors.any? { |d| !d.locked }

      # All doors are locked — unlock one at random (and its destination pair)
      door = new_doors.sample
      door.locked = false
      door.destination_door.locked = false if door.destination_door
    end

    def find_empty_position wh=nil, max_attempts=100
      wh ||= {
        w: HuskGame::Constants::SPRITE_SCALES[@scale],
        h: HuskGame::Constants::SPRITE_SCALES[@scale]
      }
      wall_doubled = HuskGame::Constants::SPRITE_SCALES[@scale] * 2
      playable_x = HuskGame::Constants::VIEWSCREEN_SIZE - wall_doubled - wh.w
      playable_x_margin = HuskGame::Constants::VIEWSCREEN_OFFSET_X + HuskGame::Constants::SPRITE_SCALES[@scale]
      playable_y = HuskGame::Constants::VIEWSCREEN_SIZE - wall_doubled - wh.h
      playable_y_margin = HuskGame::Constants::VIEWSCREEN_OFFSET_Y + HuskGame::Constants::SPRITE_SCALES[@scale]
      success = false
      loops = 0
      # puts "find_empty_position initial state: #{playable_x}, #{playable_y}, #{playable_x_margin}, #{playable_y_margin}"
      until success
        if loops > max_attempts
          puts "WARNING: find_empty_position failed after #{max_attempts} attempts for #{wh}"
          return nil
        end
        temp = {
          x: rand(playable_x) + playable_x_margin,
          y: rand(playable_y) + playable_y_margin,
          # h: $SPRITE_SCALES[@scale],
          # w: $SPRITE_SCALES[@scale]
        }.merge!(wh)
        result = $gtk.args.geometry.find_intersect_rect temp, @no_populate_buffer
        loops += 1
        success = result.nil? ? true : false # returns nil if there is *no* intersection
      end
      return {
        x: temp[:x],
        y: temp[:y]
      }
    end

    def populate_pickups
      # mark_and_print "populate_pickups"
      if rand(4) <= 3
        valid_position = find_empty_position
        return if valid_position.nil?

        boost_thrust = BoostThrust.new(
          x: valid_position[:x],
          y: valid_position[:y],
          # bounce: 0.8,
          amount: 10,
          duration: 3.seconds,
          start_duration: 10,
          scale: @scale
        )
        @pickups << boost_thrust
        @no_populate_buffer << boost_thrust.buffer
      end
      # end
      valid_position = find_empty_position
      return if valid_position.nil?

      boost_emp = BoostEmp.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale
      )
      @pickups << boost_emp
      @no_populate_buffer << boost_emp.buffer

      if @chaos >= 3 && rand(4) == 0
        valid_position = find_empty_position
        unless valid_position.nil?
          boost_data = BoostData.new(x: valid_position[:x], y: valid_position[:y], scale: @scale)
          @pickups << boost_data
          @no_populate_buffer << boost_data.buffer
        end
      end
    end

    def populate_hazards
      odds = HAZARD_ODDS[@scale]
      spawn_hazard(odds[:chance], odds[:in], effectable: false) do |x, y|
        HuskGame::Mine.new(x: x, y: y, scale: @scale)
      end

      spawn_hazard(0, 4, effectable: true) do |x, y|
        Repulsor.new(x, y, @scale)
      end

      spawn_hazard(0, 8, effectable: true) do |x, y|
        Attractor.new(x, y, @scale)
      end
    end

    def spawn_hazard(chance, out_of, effectable: false)
      return unless rand(out_of) <= chance

      valid_position = find_empty_position
      return if valid_position.nil?

      hazard = yield(valid_position[:x], valid_position[:y])

      if effectable
        setup_effectable_hazard(hazard)
      else
        hazard.deactivate
        add_hazard(hazard)
      end
    end

    def add_hazard(hazard)
      @hazards << hazard
      @no_populate_buffer << hazard.buffer
    end

    def setup_effectable_hazard(hazard)
      hazard.effect_target = $gtk.args.state.ship
      $game.services[:effect_service].register_effectable hazard
      add_hazard(hazard)
    end

    def populate_spawners
      spawner = Spawner.new(
        x: 300,
        y: 860,
        scale: @scale,
        spawn_class: :HunterBlob,
        spawn_rate: 20.seconds,
        room: self
      )
      spawner.deactivate
      @spawners << spawner
    end

    def populate_terminals
      populate_data_terminal
      populate_data_core
      populate_repairer
      populate_unlock_terminal
    end

    def populate_data_terminal
      return unless rand(1) == 0 # Always true, but keeping for potential future randomization

      valid_position = find_empty_position
      return if valid_position.nil?

      data_terminal = DataTerminal.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale,
        data: rand(1000),
        data_rate: 1 + (rand(3) * 0.5),
        facing: [:north, :south, :east, :west].sample.to_sym
      )
      add_terminal(data_terminal)
    end

    def populate_data_core
      return unless @chaos >= 3 && @husk.data_core.nil?

      valid_position = find_empty_position({ w: 128, h: 128 })
      return if valid_position.nil?

      data_core = DataCore.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale
      )
      add_terminal(data_core)
      @husk.data_core = data_core
    end

    def populate_repairer
      valid_position = find_empty_position
      return if valid_position.nil?

      repairer = Repairer.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale
      )
      add_terminal(repairer)
    end

    def populate_unlock_terminal
      # Only spawn one unlock terminal per husk
      return if @husk.nil? || @husk.unlock_terminal

      # Only spawn in rooms reachable via unlocked entrance
      # (entrypoint has nil entrance_door, so it qualifies)
      unless @entrance_door.nil?
        return if @entrance_door.locked
      end

      # Check if all non-entrance doors are locked (player would be stuck)
      non_entrance_doors = @doors.select { |d| d != @entrance_door }
      all_locked = !non_entrance_doors.empty? && non_entrance_doors.all?(&:locked)

      # Skip chaos 0, 50% chance at chaos 1, guaranteed at chaos 2+
      # UNLESS all doors are locked — force-spawn to prevent softlock
      unless all_locked
        return if @chaos == 0
        return if @chaos == 1 && rand(2) != 0
      end

      valid_position = find_empty_position
      return if valid_position.nil?

      unlock_terminal = UnlockTerminal.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale,
        facing: [:north, :south, :east, :west].sample.to_sym,
        husk: @husk
      )
      add_terminal(unlock_terminal)
      @husk.unlock_terminal = unlock_terminal
    end

    def add_terminal(terminal)
      terminal.deactivate
      @terminals << terminal
      @no_populate_buffer << terminal.buffer
    end

    def populate_agents
      # mark_and_print("populate_agents")

      # No agents in low-chaos rooms
      return if @chaos < 2

      # Higher chaos increases the chance and count of agents
      # chaos 2: 1-in-3 chance of 1 agent
      # chaos 3: 1-in-2 chance of 1 agent
      # chaos 4+: guaranteed 1 agent, 1-in-3 chance of a second
      case @chaos
      when 2
        return unless rand(3) == 0
        count = 1
      when 3
        return unless rand(2) == 0
        count = 1
      else
        count = rand(3) == 0 ? 2 : 1
      end

      count.times do
        agent = HunterBlob.new(scale: @scale)
        agent.deactivate
        @agents << agent
      end
    end

    def populate_dressings
      crate_min = {
        large: 0,
        medium: 2,
        small: 8
      }
      crate_max = {
        large: 3,
        medium: 6,
        small: 18
      }
      # Crates
      num = rand(crate_max[@scale]) + crate_min[@scale]
      num.times do
        valid_position = find_empty_position
        unless valid_position.nil?
          crate = Crate.new(
            x: valid_position[:x],
            y: valid_position[:y],
            scale: @scale
          )
          @dressings << crate
          @no_populate_buffer << crate.buffer
        end
      end

      4.times do
        valid_position = find_empty_position({ w: 128, h:128 })
        unless valid_position.nil?
          crate_big = CrateBig.new(
            x: valid_position[:x],
            y: valid_position[:y],
            scale: @scale
          )
          @dressings << crate_big
          @no_populate_buffer << crate_big.buffer
        end
      end
    end

    def populate_decorations
      # mark_and_print("populate_dressings")
      # Gash
      rand(2).times do
        gash = Gash.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: [:large, :medium, :small].sample
        )
        @decorations << gash
      end
      rand(2).times do
        cable01 = Cable01.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: :large
        )
        @decorations << cable01
      end
    end

    def populate_overlays
      @overlays << {
        x: HuskGame::Constants::VIEWSCREEN_OFFSET_X,
        y: HuskGame::Constants::VIEWSCREEN_OFFSET_Y,
        w: HuskGame::Constants::VIEWSCREEN_SIZE,
        h: HuskGame::Constants::VIEWSCREEN_SIZE,
        path: HuskGame::AssetPaths::Sprites::OVERLAY_01_LARGE
      }
    end


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
      spatial_grid = $game&.services&.named(:spatial_grid)
      return collidables unless spatial_grid

      spatial_grid.get_nearby(obj)
    end

    # Rebuild the spatial grid for collision optimization
    def rebuild_spatial_grid
      spatial_grid = $game&.services&.named(:spatial_grid)
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
      spatial_grid = $game&.services&.named(:spatial_grid)
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