# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Room
  attr_accessor :name,
                :chaos,
                :entrance_door,
                :tiles_target,
                :tile_dimensions,
                :scale,
                :doors,
                :doors_bits,
                :doors_hash,
                :hazards,
                :pickups,
                :terminals

  DOORS = {
    none: 0,
    north: 1,
    east: 2,
    south: 4,
    west: 8
  }.freeze
  DOOR_BITS = {
    none: 0,
    north: 1,
    east: 2,
    south: 4,
    west: 8
  }.freeze

  # rubocop:disable Metrics/MethodLength
  def initialize(
    name: 'entrance',
    chaos: 0,
    scale: :large,
    entrance_door: nil
  )
    # Set variables
    @name = name
    @chaos = chaos
    @scale = scale
    pixel_scale = $SPRITE_SCALES[@scale]
    @tile_dimensions = 640.div(pixel_scale)
    @tiles_target = Zif::RenderTarget.new(@name, width: 640, height: 640)
    @doors = []
    @hazards = []
    @pickups = []
    @terminals = []
    @doors_hash = {
      north: nil,
      south: nil,
      east: nil,
      west: nil
    }

    @no_populate_buffer = []

    create_tiles

    unless entrance_door.nil?
      @doors_hash[entrance_door.door_side] = entrance_door
      @doors << entrance_door
    end

    populate_doors
    populate_pickups
    populate_hazards
    populate_terminals

    # create a dummy DataTerminal
    # @data_terminal = DataTerminal.new(x: 360, y: 900, scale: @scale)
    # @terminals << @data_terminal

    # This is dumping to args for Palantir
    $gtk.args.state.rooms[@name] = { doors: @doors }

    # puts "\n\nnew room doors: #{@doors}\n\n"
  end
  # rubocop:enable Metrics/MethodLength

  def populate_doors
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
  end

  def find_empty_position
    playable_x = 640 - ($SPRITE_SCALES[@scale] * 2) - $SPRITE_SCALES[@scale] # That last one is for the thing itself
    playable_x_margin = 40 + $SPRITE_SCALES[@scale]
    playable_y = 640 - ($SPRITE_SCALES[@scale] * 2) - $SPRITE_SCALES[@scale]
    playable_y_margin = 560 + $SPRITE_SCALES[@scale]
    success = false
    until success
      temp = {
        # x: rand(600) + 40 - 32,
        # y: rand(640) + 600 - 32,
        x: rand(playable_x) + playable_x_margin,
        y: rand(playable_y) + playable_y_margin,
        h: $SPRITE_SCALES[@scale],
        w: $SPRITE_SCALES[@scale]
      }
      result = $gtk.args.geometry.find_intersect_rect temp, @no_populate_buffer
      success = result.nil? ? true : false
    end
    return {
      x: temp[:x],
      y: temp[:y]
    }
  end

  def populate_pickups
    success = false
    until success
      temp = {
        x: rand(600) + 40 - 32,
        y: rand(640) + 600 - 32,
        h: $SPRITE_SCALES[@scale],
        w: $SPRITE_SCALES[@scale]
      }
      result = $gtk.args.geometry.find_intersect_rect temp, @no_populate_buffer
      success = result.nil? ? true : false
    end

    boost_thrust = BoostThrust.new(
      # rand(600) + 40 - 32,
      # rand(640) + 600 - 32,
      temp[:x],
      temp[:y],
      0.8,
      10,
      3.seconds,
      10,
      @scale
    )
    @pickups << boost_thrust
    # end
  end

  def populate_hazards
    if rand(4) <= 3
      valid_position = find_empty_position

      mine = Mine.new(
        # rand(600) + 40 - 32,
        # rand(640) + 600 - 32,
        valid_position[:x],
        valid_position[:y],
        @scale
      )
      @hazards << mine
      @no_populate_buffer << mine.buffer
    end
    if rand(4) == 3
      valid_position = find_empty_position

      repulsor = Repulsor.new(
        # rand(600) + 40 - 32,
        # rand(640) + 600 - 32,
        valid_position[:x],
        valid_position[:y],
        @scale
      )
      repulsor.effect_target = $game.scene.ship
      $game.services[:effect_service].register_effectable repulsor
      @hazards << repulsor
      @no_populate_buffer << repulsor.buffer
    end
    if rand(8) == 7
      valid_position = find_empty_position

      attractor = Attractor.new(
        # rand(600) + 40 - 32,
        # rand(640) + 600 - 32,
        valid_position[:x],
        valid_position[:y],
        @scale
      )
      attractor.effect_target = $game.scene.ship
      $game.services[:effect_service].register_effectable attractor
      @hazards << attractor
      @no_populate_buffer << attractor.buffer
    end
  end

  def populate_terminals
    if rand(1) == 0
      valid_position = find_empty_position

      data_terminal = DataTerminal.new(
        # x: rand(600) + 40 - 32,
        # y: rand(640) + 600 - 32,
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale,
        data: rand(1000),
        data_rate: rand(4) * 0.5,
        facing: [:north, :south, :east, :west].sample.to_sym
      )
      @terminals << data_terminal
      @no_populate_buffer << data_terminal.buffer
    end
  end

  def renders
    (@pickups + @hazards + @terminals).reject(&:is_dead)
  end

  def renders_under_player
    (@pickups + @hazards).reject(&:is_dead) + @terminals
  end

  def renders_over_player
    @walls
  end

  def collidables
    @walls + (@pickups + @hazards).reject(&:is_dead) + @terminals
  end

  def activate
    @hazards.each { |h| h.activate if h.is_a?(Effectable) }
  end

  def deactivate
    @hazards.each { |h| h.deactivate if h.is_a?(Effectable) }
  end

  def purge_deads
    # puts "Bring out your dead!"
    @pickups.reject!(&:is_dead)
    @hazards.reject!(&:is_dead)
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
    viewscreen_offset_x = 40
    viewscreen_offset_y = 560
    pixel_scale = $SPRITE_SCALES[@scale]

    # Create tiles
    @walls = []
    # @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
    @tile_dimensions.times do |x|
      @tile_dimensions.times do |y|
        if y.zero?
          # this is the south row
          @walls << if x.zero?
            # this is the southwest corner
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :southwest,
              @scale
            )
          elsif x == @tile_dimensions - 1
            # this is the southeast corner
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :southeast,
              @scale
            )
          else
            # this is the south row
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :south,
              @scale
            )
                    end
        elsif y == @tile_dimensions - 1
          # this is the north row
          @walls << if x.zero?
            # this is the northwest corner
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :northwest,
              @scale
            )
          elsif x == @tile_dimensions - 1
            # this is the northeast corner
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :northeast,
              @scale
            )
          else
            # this is the north row
            Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :north,
              @scale
            )
                    end
        elsif x.zero?
          # this is a middle row
          @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :west,
              @scale
            )
            # this is a west edge
          elsif x == @tile_dimensions - 1
            # this is a east edge
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :east,
              @scale
            )
          else
            # this is the floor
            @tiles_target.sprites << Zif::Sprite.new.tap do |s|
              s.x = x * pixel_scale
              s.y = y * pixel_scale
              s.w = pixel_scale
              s.h = pixel_scale
              s.angle = rand(4) * 90
              s.path = "sprites/1bit_floor_#{pixel_scale}_0#{rand(6)}.png"
            end
        end
      end
    end

    # This forces the creation of the containing_sprite
    puts "\n\nContaining sprite: #{@tiles_target.containing_sprite.nil?}"
  end
end
