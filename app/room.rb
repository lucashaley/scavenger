class Room
  attr_accessor :name, :chaos, :referring_door
  attr_accessor :tiles_target
  attr_accessor :tile_dimensions, :scale
  attr_accessor :doors, :doors_bits, :doors_hash
  attr_accessor :hazards
  attr_accessor :pickups
  attr_accessor :terminals

  DOORS = {
    none:   0,
    north:  1,
    east:   2,
    south:  4,
    west:   8
  }

  TILE_SIZE = {
    small: 16,
    medium: 32,
    large: 64
  }

  def initialize (
    name: 'test room',
    referring_door: nil,
    chaos: 0,
    # scale: :large
    scale:
  )
    # puts "\n\nCreating new room: #{name}, #{scale}, #{referring_door}, #{chaos}"

    # Initialize variables
    @name = name
    @chaos = chaos
    @scale = scale.nil? ? TILE_SIZE.keys.sample : scale
    @referring_door = referring_door
    # @tile_dimensions = tile_dimensions
    pixel_scale = TILE_SIZE[scale]
    @tile_dimensions = 640.div(pixel_scale)
    @tiles_target = Zif::RenderTarget.new(@name, width: 640, height: 640)
    @doors = []
    @hazards = []
    @pickups = []
    @terminals = []

    # Create doors
    # ============

    # Not used yet
    @doors_hash = {
      north: nil,
      south: nil,
      east: nil,
      west: nil
    }

    # Has to be a better way
    @doors_bits = 0
    @exit_side = :none
    # puts @referring_door
    # puts @referring_door.nil?
    unless @referring_door.nil?
      puts "\nreferring_door.door_side: #{@referring_door.door_side}"
      @exit_side = case @referring_door.door_side
      when :north
        :south
      when :south
        :north
      when :east
        :west
      when :west
        :east
      end
      @doors_bits = case @referring_door.door_side
      when :north
        DOORS[:south]
      when :south
        DOORS[:north]
      when :east
        DOORS[:west]
      when :west
        DOORS[:east]
      end

      create_door(@exit_side, @referring_door.room)
    end

    # add on any other doors
    # generate the bitmask
    # If this is the first room, make sure there is at least one door
    # Here is also where we can use chaos?
    if rand(3)+1 > @chaos
      # then we can make new rooms
      # puts "lets make new rooms"
      new_mask = @exit_side == :none ? rand(15)+1 : rand(16)
      @doors_bits |= new_mask
      # puts "doors_bits: #{@doors_bits}"
      not_doors_bits = @doors_bits ^ DOORS[@exit_side]
      # puts "not doors bits: #{not_doors_bits}"

      # There's probably an elegant ruby way of doing this
      if (not_doors_bits & DOORS[:north]).positive?
        # puts "#{name}: create a door on the north side"
        create_door :north
      end
      if (not_doors_bits & DOORS[:east]).positive?
        # puts "#{name}: create a door on the east side"
        create_door :east
      end
      if (not_doors_bits & DOORS[:south]).positive?
        # puts "#{name}: create a door on the south side"
        create_door :south
      end
      if (not_doors_bits & DOORS[:west]).positive?
        # puts "#{name}: create a door on the west side"
        create_door :west
      end
    else
      # puts "lets not make new rooms"
    end

    # Create tiles
    # ============
    viewscreen_offset_x = 40
    viewscreen_offset_y = 560

    # Create tiles
    @walls = []
    # @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
    @tile_dimensions.times do |x|
      @tile_dimensions.times do |y|
        if y==0
          # this is the south row
          if x==0
            # this is the southwest corner
            # @tiles[x][y] = {
            #   x: x * pixel_scale,
            #   y: y * pixel_scale,
            #   w: pixel_scale,
            #   h: pixel_scale,
            #   path: "sprites/wall/wall_southwest_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :southwest,
              @scale
            )
          elsif x==@tile_dimensions-1
            # this is the southeast corner
            # @tiles[x][y] = {
            #   x: x * pixel_scale,
            #   y: y * pixel_scale,
            #   w: pixel_scale,
            #   h: pixel_scale,
            #   path: "sprites/wall/wall_southeast_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :southeast,
              @scale
            )
          else
            # this is the south row
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_south_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :south,
              @scale
            )
          end
        elsif y==@tile_dimensions-1
          # this is the north row
          if x==0
            # this is the northwest corner
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_northwest_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :northwest,
              @scale
            )
          elsif x==@tile_dimensions-1
            # this is the northeast corner
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_northeast_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :northeast,
              @scale
            )
          else
            # this is the north row
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_north_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :north,
              @scale
            )
          end
        else
          # this is a middle row
          if x==0
            # this is a west edge
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_west_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :west,
              @scale
            )
          elsif x==@tile_dimensions-1
            # this is a east edge
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   path: "sprites/wall/wall_east_#{scale}.png"
            # }
            @walls << Wall.new(
              (x * TILE_SIZE[scale]) + viewscreen_offset_x,
              (y * TILE_SIZE[scale]) + viewscreen_offset_y,
              0.8,
              :east,
              @scale
            )
          else
            # this is the floor
            # @tiles[x][y] = {
            #   x: x * TILE_SIZE[scale],
            #   y: y * TILE_SIZE[scale],
            #   w: TILE_SIZE[scale],
            #   h: TILE_SIZE[scale],
            #   angle: rand(4) * 90,
            #   path: "sprites/1bit_floor_#{pixel_scale}_0#{rand(6)}.png"
            # }

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
        # @tiles[x][y] = {
        #   x: x * TILE_SIZE[scale],
        #   y: y * TILE_SIZE[scale],
        #   w: TILE_SIZE[scale],
        #   h: TILE_SIZE[scale],
        #   angle: rand(4) * 90,
        #   path: "sprites/1bit_floor_#{TILE_SIZE[scale]}_0#{rand(6)}.png"
        # }
      end
      # puts "\n\ntiles_target: #{@tiles_target.sprites}\n"
    end

    # This forces the creation of the containing_sprite
    puts "\n\nContaining sprite: #{@tiles_target.containing_sprite.nil?}"

    # Create pickups
    boost_thrust = BoostThrust.new(
      $services[:sprite_registry].construct(:pickup_64),
      (rand(600)+40) - 32,
      (rand(640)+600) - 32,
      0.8,
      10,
      3.seconds,
      10,
      @scale
    )
    @pickups << boost_thrust
    if rand(4) == 3
      mine = Mine.new(
        $services[:sprite_registry].construct(:mine_64),
        (rand(600)+40) - 32,
        (rand(640)+600) - 32,
      )
      @hazards << mine
    end
    if rand(10) == 9
      repulsor = Repulsor.new(
        $services[:sprite_registry].construct(:effector_64),
        (rand(600)+40) - 32,
        (rand(640)+600) - 32,
      )
      repulsor.effect_target = $game.scene.ship
      $game.services[:effect_service].register_effectable repulsor
      @hazards << repulsor
    end
    if rand(8) == 7
      attractor = Attractor.new(
        $services[:sprite_registry].construct(:effector_64),
        (rand(600)+40) - 32,
        (rand(640)+600) - 32,
      )
      attractor.effect_target = $game.scene.ship
      $game.services[:effect_service].register_effectable attractor
      @hazards << attractor
    end

    # Add a door for testing
    # test_door = Door.new(
    #   $services[:sprite_registry].construct(:wall2_08),
    #   300,
    #   1000,
    #   0.8,
    #   :east,
    #   self,
    #   self,
    #   :large
    # )
    # # puts "\ntest door: #{test_door}\n\n"
    # @doors << test_door
    # puts @doors.collect(&:name)
  end

  def create_door side, returns_to=nil
    door_x = door_y = 0
    prim = nil
    case side
    when :north
      door_x = (360)
      door_y = (1280 - 80 - TILE_SIZE[scale])
      prim = :doorh_128
    when :south
      door_x = (360 - TILE_SIZE[scale])
      door_y = (1280 - 80 - 640)
      prim = :doorh_128
    when :east
      door_x = (720 - 40 - TILE_SIZE[scale])
      door_y = (1280 - 80 - 320 - TILE_SIZE[scale])
      prim = :doorv_128
    when :west
      # door_x = (40 - TILE_SIZE[scale])
      door_x = 40
      door_y = (1280 - 80 - 320 - TILE_SIZE[scale])
      prim = :doorv_128
    end

    # puts "create_door: #{self}, #{side}, #{returns_to}"
    puts "Random size: #{TILE_SIZE.keys.sample}"
    door = Door.new(
      $services[:sprite_registry].construct(prim),
      door_x,
      door_y,
      0.8,
      side,
      self,
      returns_to,
      @scale
      # TILE_SIZE.keys.sample
    )
    @doors << door
  end

  def renders
    (@pickups + @hazards + @terminals).reject{ |p| p.is_dead }
  end

  def renders_under_player
    (@pickups + @hazards + @terminals).reject{ |p| p.is_dead }
  end
  def renders_over_player
    @walls
  end

  def collidables
    @walls + ((@pickups + @hazards + @terminals).reject{ |p| p.is_dead })
  end

  def activate
    @hazards.each { |h| h.activate if h.is_a?(Effectable) }
  end

  def deactivate
    @hazards.each { |h| h.deactivate if h.is_a?(Effectable) }
  end

  def purge_deads
    # puts "Bring out your dead!"
    @pickups.reject! { |p| p.is_dead }
    @hazards.reject! { |p| p.is_dead }
  end

  def serialize
    {
      name: @name,
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
end
