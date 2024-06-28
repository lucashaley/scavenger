class Room
  attr_accessor :name
  attr_accessor :tiles, :tile_dimensions
  attr_accessor :doors
  attr_accessor :hazards
  attr_accessor :pickups
  attr_accessor :terminals

  def initialize (
    name='test room',
    tile_dimensions=10
  )
    puts "Creating new room"

    # Initialize variables
    @name = name
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

    # Create doors
    door = Door.new(
      $services[:sprite_registry].construct(:doorh_128),
      360 - 64,
      1200
    )
    @doors << door
    door_left = Door.new(
      $services[:sprite_registry].construct(:doorv_128),
      32,
      900,
      1.5,
      :east
    )
    @doors << door_left

    # Create pickups
    boost_thrust = BoostThrust.new(
      $services[:sprite_registry].construct(:pickup_64),
      360 + 10,
      800,
      0.8,
      1
    )
    @pickups << boost_thrust
    mine = Mine.new(
      $services[:sprite_registry].construct(:mine_64),
      360,
      900
    )
    @hazards << mine
  end

  def collidables
    (@pickups + @hazards + @terminals).reject{ |p| p.is_dead }
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
