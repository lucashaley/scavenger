class Room
  attr_accessor :name, :chaos, :entrance_door
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
  DOOR_BITS = {
    none:   0,
    north:  1,
    east:   2,
    south:  4,
    west:   8
  }

  # TILE_SIZE = {
  #   small: 16,
  #   medium: 32,
  #   large: 64
  # }

  def initialize (
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

    create_tiles

    unless entrance_door.nil?
      @doors_hash[entrance_door.door_side] = entrance_door
      @doors << entrance_door
    end

    populate_doors

    puts "\n\nnew room doors: #{@doors}\n\n"
  end

  # def initialize (
  #   name: 'test room',
  #   referring_door: nil,
  #   chaos: 0,
  #   # scale: :large
  #   scale:
  # )
  #   # puts "\n\nCreating new room: #{name}, #{scale}, #{referring_door}, #{chaos}"
  #
  #   # Initialize variables
  #   @name = name
  #   @chaos = chaos
  #   @scale = scale.nil? ? TILE_SIZE.keys.sample : scale
  #   @referring_door = referring_door
  #   # @tile_dimensions = tile_dimensions
  #   pixel_scale = TILE_SIZE[scale]
  #   @tile_dimensions = 640.div(pixel_scale)
  #   @tiles_target = Zif::RenderTarget.new(@name, width: 640, height: 640)
  #   @doors = []
  #   @hazards = []
  #   @pickups = []
  #   @terminals = []
  #
  #   # Has to be a better way
  #   @doors_bits = 0
  #   @exit_side = :none
  #
  #
  #   # Make the door back from whence we came
  #   unless @referring_door.nil?
  #     # puts "\nreferring_door.door_side: #{@referring_door.door_side}"
  #     # @exit_side = case @referring_door.door_side
  #     # when :north
  #     #   :south
  #     # when :south
  #     #   :north
  #     # when :east
  #     #   :west
  #     # when :west
  #     #   :east
  #     # end
  #     # @doors_bits = case @referring_door.door_side
  #     # when :north
  #     #   DOORS[:south]
  #     # when :south
  #     #   DOORS[:north]
  #     # when :east
  #     #   DOORS[:west]
  #     # when :west
  #     #   DOORS[:east]
  #     # end
  #     #
  #     # # create_door(@exit_side, @referring_door.room) # This version passes the room
  #     # create_door(@exit_side, @referring_door) # This passes the door itself
  #     add_connecting_door referring_door
  #   end
  #
  #   # add on any other doors
  #   # generate the bitmask
  #   # If this is the first room, make sure there is at least one door
  #   # Here is also where we can use chaos?
  #   # if rand(3)+1 > @chaos
  #   #   # then we can make new rooms
  #   #   # puts "lets make new rooms"
  #   #   new_mask = @exit_side == :none ? rand(15)+1 : rand(16)
  #   #   @doors_bits |= new_mask
  #   #   # puts "doors_bits: #{@doors_bits}"
  #   #   not_doors_bits = @doors_bits ^ DOORS[@exit_side]
  #   #   # puts "not doors bits: #{not_doors_bits}"
  #   #
  #   #   # There's probably an elegant ruby way of doing this
  #   #   if (not_doors_bits & DOORS[:north]).positive?
  #   #     # puts "#{name}: create a door on the north side"
  #   #     create_door :north
  #   #   end
  #   #   if (not_doors_bits & DOORS[:east]).positive?
  #   #     # puts "#{name}: create a door on the east side"
  #   #     create_door :east
  #   #   end
  #   #   if (not_doors_bits & DOORS[:south]).positive?
  #   #     # puts "#{name}: create a door on the south side"
  #   #     create_door :south
  #   #   end
  #   #   if (not_doors_bits & DOORS[:west]).positive?
  #   #     # puts "#{name}: create a door on the west side"
  #   #     create_door :west
  #   #   end
  #   # else
  #   #   # puts "lets not make new rooms"
  #   # end
  #   populate_doors
  #
  #   # # Create tiles
  #   # # ============
  #   # viewscreen_offset_x = 40
  #   # viewscreen_offset_y = 560
  #   #
  #   # # Create tiles
  #   # @walls = []
  #   # # @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
  #   # @tile_dimensions.times do |x|
  #   #   @tile_dimensions.times do |y|
  #   #     if y==0
  #   #       # this is the south row
  #   #       if x==0
  #   #         # this is the southwest corner
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :southwest,
  #   #           @scale
  #   #         )
  #   #       elsif x==@tile_dimensions-1
  #   #         # this is the southeast corner
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :southeast,
  #   #           @scale
  #   #         )
  #   #       else
  #   #         # this is the south row
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :south,
  #   #           @scale
  #   #         )
  #   #       end
  #   #     elsif y==@tile_dimensions-1
  #   #       # this is the north row
  #   #       if x==0
  #   #         # this is the northwest corner
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :northwest,
  #   #           @scale
  #   #         )
  #   #       elsif x==@tile_dimensions-1
  #   #         # this is the northeast corner
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :northeast,
  #   #           @scale
  #   #         )
  #   #       else
  #   #         # this is the north row
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :north,
  #   #           @scale
  #   #         )
  #   #       end
  #   #     else
  #   #       # this is a middle row
  #   #       if x==0
  #   #         # this is a west edge
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :west,
  #   #           @scale
  #   #         )
  #   #       elsif x==@tile_dimensions-1
  #   #         # this is a east edge
  #   #         @walls << Wall.new(
  #   #           (x * TILE_SIZE[scale]) + viewscreen_offset_x,
  #   #           (y * TILE_SIZE[scale]) + viewscreen_offset_y,
  #   #           0.8,
  #   #           :east,
  #   #           @scale
  #   #         )
  #   #       else
  #   #         # this is the floor
  #   #         @tiles_target.sprites << Zif::Sprite.new.tap do |s|
  #   #           s.x = x * pixel_scale
  #   #           s.y = y * pixel_scale
  #   #           s.w = pixel_scale
  #   #           s.h = pixel_scale
  #   #           s.angle = rand(4) * 90
  #   #           s.path = "sprites/1bit_floor_#{pixel_scale}_0#{rand(6)}.png"
  #   #         end
  #   #       end
  #   #     end
  #   #   end
  #   # end
  #   #
  #   # # This forces the creation of the containing_sprite
  #   # puts "\n\nContaining sprite: #{@tiles_target.containing_sprite.nil?}"
  #
  #   # Create pickups
  #   # boost_thrust = BoostThrust.new(
  #   #   $services[:sprite_registry].construct(:pickup_64),
  #   #   (rand(600)+40) - 32,
  #   #   (rand(640)+600) - 32,
  #   #   0.8,
  #   #   10,
  #   #   3.seconds,
  #   #   10,
  #   #   @scale
  #   # )
  #   # @pickups << boost_thrust
  #   # if rand(4) == 3
  #   #   mine = Mine.new(
  #   #     $services[:sprite_registry].construct(:mine_64),
  #   #     (rand(600)+40) - 32,
  #   #     (rand(640)+600) - 32,
  #   #   )
  #   #   @hazards << mine
  #   # end
  #   # if rand(10) == 9
  #   #   repulsor = Repulsor.new(
  #   #     $services[:sprite_registry].construct(:effector_64),
  #   #     (rand(600)+40) - 32,
  #   #     (rand(640)+600) - 32,
  #   #   )
  #   #   repulsor.effect_target = $game.scene.ship
  #   #   $game.services[:effect_service].register_effectable repulsor
  #   #   @hazards << repulsor
  #   # end
  #   # if rand(8) == 7
  #   #   attractor = Attractor.new(
  #   #     $services[:sprite_registry].construct(:effector_64),
  #   #     (rand(600)+40) - 32,
  #   #     (rand(640)+600) - 32,
  #   #   )
  #   #   attractor.effect_target = $game.scene.ship
  #   #   $game.services[:effect_service].register_effectable attractor
  #   #   @hazards << attractor
  #   # end
  # end

  # def populate_doors
  #   # add on any other doors
  #   # generate the bitmask
  #   # If this is the first room, make sure there is at least one door
  #   # Here is also where we can use chaos?
  #   if rand(3)+1 > @chaos
  #     # then we can make new rooms
  #     # puts "lets make new rooms"
  #     new_mask = @exit_side == :none ? rand(15)+1 : rand(16)
  #     @doors_bits |= new_mask
  #     # puts "doors_bits: #{@doors_bits}"
  #     not_doors_bits = @doors_bits ^ DOORS[@exit_side]
  #     # puts "not doors bits: #{not_doors_bits}"
  #
  #     # There's probably an elegant ruby way of doing this
  #     if (not_doors_bits & DOORS[:north]).positive?
  #       # puts "#{name}: create a door on the north side"
  #       create_door :north
  #     end
  #     if (not_doors_bits & DOORS[:east]).positive?
  #       # puts "#{name}: create a door on the east side"
  #       create_door :east
  #     end
  #     if (not_doors_bits & DOORS[:south]).positive?
  #       # puts "#{name}: create a door on the south side"
  #       create_door :south
  #     end
  #     if (not_doors_bits & DOORS[:west]).positive?
  #       # puts "#{name}: create a door on the west side"
  #       create_door :west
  #     end
  #   else
  #     # puts "lets not make new rooms"
  #   end
  # end

  def populate_doors
    @doors_hash.each do |key, value|
      if value.nil?
        # there are no doors on this side yet
        if rand(3)+1 > @chaos
          # Let's make a new door
          new_door = Door.new(
            scale: @scale,
            door_side: key.to_sym,
            room: self
          )
          @doors_hash[key] = new_door
          @doors << new_door
        end
      end
    end
  end

  def populate_pickups
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
  end

  def populate_hazards odds
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
  end

  # This creates a door.
  # The room beyond is automatically populated in the Door class.
  # def create_door side, connecting_door=nil
  def create_door side
    pixel_scale = $SPRITE_SCALES[scale]

    puts "room create_door: #{side}, #{returns_to}"
    door_x = door_y = 0
    case side
    when :north
      door_x = (360)
      door_y = (1280 - 80 - pixel_scale)
    when :south
      door_x = (360 - pixel_scale)
      door_y = (1280 - 80 - 640)
    when :east
      door_x = (720 - 40 - pixel_scale)
      door_y = (1280 - 80 - 320 - pixel_scale)
    when :west
      # door_x = (40 - TILE_SIZE[scale])
      door_x = 40
      door_y = (1280 - 80 - 320 - pixel_scale)
    end

    # puts "create_door: #{self}, #{side}, #{returns_to}"
    puts "Random size: #{$SPRITE_SCALES.keys.sample}"
    door = Door.new(
      x: door_x,
      y: door_y,
      bounce: 0.8,
      room: self,
      door_side: side,
      # connecting_door: connecting_door,
      scale: @scale
    )

    # connect the existing door
    # returns_to&.connecting_door = door

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

  def create_tiles
    viewscreen_offset_x = 40
    viewscreen_offset_y = 560
    pixel_scale = $SPRITE_SCALES[@scale]

    # Create tiles
    @walls = []
    # @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
    @tile_dimensions.times do |x|
      @tile_dimensions.times do |y|
        if y==0
          # this is the south row
          if x==0
            # this is the southwest corner
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :southwest,
              @scale
            )
          elsif x==@tile_dimensions-1
            # this is the southeast corner
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :southeast,
              @scale
            )
          else
            # this is the south row
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :south,
              @scale
            )
          end
        elsif y==@tile_dimensions-1
          # this is the north row
          if x==0
            # this is the northwest corner
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :northwest,
              @scale
            )
          elsif x==@tile_dimensions-1
            # this is the northeast corner
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :northeast,
              @scale
            )
          else
            # this is the north row
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :north,
              @scale
            )
          end
        else
          # this is a middle row
          if x==0
            # this is a west edge
            @walls << Wall.new(
              (x * pixel_scale) + viewscreen_offset_x,
              (y * pixel_scale) + viewscreen_offset_y,
              0.8,
              :west,
              @scale
            )
          elsif x==@tile_dimensions-1
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
    end

    # This forces the creation of the containing_sprite
    puts "\n\nContaining sprite: #{@tiles_target.containing_sprite.nil?}"
  end
end
