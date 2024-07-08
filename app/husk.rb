class Husk
  attr_accessor :health, :deterioration_rate, :deterioration_progress
  attr_accessor :current_room, :rooms, :room_dimensions

  DOORS = {
    north:  1,
    east:   2,
    south:  4,
    west:   8
  }

  DETERIORATION_SCALE = 0.000001

  def initialize (
    density=0.6,
    room_dimensions=7
  )
    # Variables
    @health = 1.0
    @deterioration_rate = 100 * DETERIORATION_SCALE

    @room_dimensions = room_dimensions
    # @rooms = Array.new(@room_dimensions){Array.new(@room_dimensions)}

    # Create the rooms
    # theoretical_number_of_rooms = ((@room_dimensions ** 2) * density).truncate
    # puts "number of rooms: #{theoretical_number_of_rooms}"
    # @rooms = Array.new(@room_dimensions){Array.new(@room_dimensions)}

    # Some solutions:
    #
    # https://youtu.be/JYafic4lkK4
    # https://catlikecoding.com/unity/tutorials/prototypes/maze-2/

    # Randomly fill in the grid
    # @room_dimensions.times do |x|
    #   @room_dimensions.times do |y|
    #     @rooms[x][y] = Room.new unless rand > density
    #   end
    # end
    #
    # @room_dimensions.times do |x|
    #   @room_dimensions.times do |y|
    #     if @rooms[x-1][y]
    #       puts "needs left door"
    #     end
    #     if @rooms[x+1][y]
    #       puts "needs right door"
    #     end
    #     if @rooms[x][y-1]
    #       puts "needs top door"
    #     end
    #   end
    # end

    # Start with the entrypoint
    # midpoint = @room_dimensions.div 2
    # door_bits = rand(16)
    # @rooms[midpoint][midpoint] = Room.new('entrypoint', 10, :west, 3)


    # if (door_bits & DOORS[:north]).positive?
    #   puts "create a room on the north side"
    #   @rooms[midpoint-1][midpoint] = Room.new('north', 10, :north, @rooms[midpoint][midpoint])
    # end
    # if (door_bits & DOORS[:east]).positive?
    #   puts "create a room on the east side"
    #   @rooms[midpoint][midpoint+1] = Room.new('east', 10, :east, @rooms[midpoint][midpoint])
    # end
    # if (door_bits & DOORS[:south]).positive?
    #   puts "create a room on the south side"
    #   @rooms[midpoint+1][midpoint] = Room.new('south', 10, :south, @rooms[midpoint][midpoint])
    # end
    # if (door_bits & DOORS[:west]).positive?
    #   puts "create a room on the east side"
    #   @rooms[midpoint][midpoint-1] = Room.new('west', 10, :west, @rooms[midpoint][midpoint])
    # end
    # puts @rooms

    # Chaos method:

    @entrypoint = Room.new('entrypoint', 10, nil, 0)
    switch_rooms @entrypoint
    # @current_room = @entrypoint

    # UI Progress bar
    @deterioration_progress = ExampleApp::ProgressBar.new(:count_progress, 400, 0, :white)
    @deterioration_progress.x = 360 - (400 * 0.5)
    @deterioration_progress.y = 1200
    @deterioration_progress.view_actual_size!
    # @deterioration_progress.hide
  end

  def switch_rooms room
    @current_room.deactivate unless @current_room.nil?
    @current_room = room
    @current_room.activate
  end

  def calc_health
    @health -= @deterioration_rate
    # puts "health: #{@health}"
    @deterioration_progress.progress = @health

    # Game over!
    # $game.scene.game_over if @health <= 0
  end

  # I don't like to work with such small values
  # so I'm clamping from 0-100 and scaling here
  def damage amount
    puts "damaging hull"
    @deterioration_rate += amount.clamp(0, 100) * DETERIORATION_SCALE
    puts @deterioration_rate
  end

  def create_room
    puts "Husk: create_room"
  end

  def serialize
    {
      health: @health,
      current_room: @current_room,
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
