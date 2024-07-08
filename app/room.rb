class Room
  attr_accessor :name, :chaos, :referring_door
  attr_accessor :tiles, :tile_dimensions
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

  def initialize (
    name='test room',
    tile_dimensions=10,
    referring_door=nil,
    chaos=0
  )
    puts "\n\nCreating new room: #{name}, #{tile_dimensions}, #{referring_door}, #{chaos}"

    # Initialize variables
    @name = name
    @chaos = chaos
    @referring_door = referring_door
    @tile_dimensions = tile_dimensions
    @doors = []
    @hazards = []
    @pickups = []
    @terminals = []

    # Create tiles
    @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
    @tile_dimensions.times do |x|
      @tile_dimensions.times do |y|
        # @tile_array[x][y] = { x: x * 64, y: y * 64, w: 64, h: 64, path: "sprites/walltop_64.png" }
        @tiles[x][y] = {
          x: x * 64,
          y: y * 64,
          w: 64,
          h: 64,
          angle: rand(4) * 90,
          path: "sprites/1bit_floor_64_0#{rand(6)}.png" }
      end
    end

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
      puts "#{self}: creating referring door: #{@exit_side}, #{@doors_bits}"
      # @doors << Door.new(
      #   $services[:sprite_registry].construct(:doorh_128),
      #   360 - 64,
      #   1200,
      #   0.8,
      #   @exit_side,
      #   self,
      #   @referring_door.room
      # )

      ### THIS RIGHT HERE
      ### IS SUPER RECURSIVE
      create_door(@exit_side, @referring_door.room)
      ###
      ###
    end

    # old way
    # @doors_bits = DOORS[@exit_side]
    puts "\n\nCreating new rooms"
    puts "doors_bits: #{@doors_bits}"

    # Check if there is an exit
    # unless @exit_side == :none
    #   # Create the referring door
    #   puts "#{self}: creating referring door"
    #   @doors << Door.new(
    #     $services[:sprite_registry].construct(:doorh_128),
    #     360 - 64,
    #     1200,
    #     0.8,
    #     @exit_side,
    #     self,
    #     @referring_door
    #   )
    # end

    # add on any other doors
    # generate the bitmask
    # If this is the first room, make sure there is at least one door
    # Here is also where we can use chaos?
    if rand(3)+1 > @chaos
      # then we can make new rooms
      puts "lets make new rooms"
      new_mask = @exit_side == :none ? rand(15)+1 : rand(16)
      @doors_bits |= new_mask
      puts "doors_bits: #{@doors_bits}"
      not_doors_bits = @doors_bits ^ DOORS[@exit_side]
      puts "not doors bits: #{not_doors_bits}"

      # There's probably an elegant ruby way of doing this
      if (not_doors_bits & DOORS[:north]).positive?
        puts "#{name}: create a door on the north side"
        create_door :north
      end
      if (not_doors_bits & DOORS[:east]).positive?
        puts "#{name}: create a door on the east side"
        create_door :east
      end
      if (not_doors_bits & DOORS[:south]).positive?
        puts "#{name}: create a door on the south side"
        create_door :south
      end
      if (not_doors_bits & DOORS[:west]).positive?
        puts "#{name}: create a door on the west side"
        create_door :west
      end
    else
      puts "lets not make new rooms"
    end

    # Create pickups
    boost_thrust = BoostThrust.new(
      $services[:sprite_registry].construct(:pickup_64),
      (rand(600)+40) - 32,
      (rand(640)+600) - 32,
      0.8,
      1
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
  end

  def create_door side, returns_to=nil
    door_x = door_y = 0
    prim = nil
    case side
    when :north
      door_x = (360 - 64)
      door_y = (1280 - 40 - 32)
      prim = :doorh_128
    when :south
      door_x = (360 - 64)
      door_y = (1280 - 40 - 640 - 32)
      prim = :doorh_128
    when :east
      door_x = (720 - 40 - 32)
      door_y = (1280 - 40 - 320 - 64)
      prim = :doorv_128
    when :west
      door_x = (40 - 32)
      door_y = (1280 - 40 - 320 - 64)
      prim = :doorv_128
    end

    puts "create_door: #{self}, #{side}, #{returns_to}"
    door = Door.new(
      $services[:sprite_registry].construct(prim),
      door_x,
      door_y,
      0.8,
      side,
      self,
      returns_to
    )
    @doors << door
  end

  def collidables
    (@pickups + @hazards + @terminals).reject{ |p| p.is_dead }
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
