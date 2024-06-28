class Husk
  attr_accessor :health
  attr_accessor :rooms, :room_dimensions

  DOOR_DIRECTIONS = {
    north:  1,
    east:   2,
    south:  4,
    west:   8
  }

  def initialize (
    density=0.6,
    room_dimensions=7
  )
    # Variables
    @room_dimensions = room_dimensions
    @rooms = Array.new(@room_dimensions){Array.new(@room_dimensions)}

    # Create the rooms
    theoretical_number_of_rooms = ((@room_dimensions ** 2) * density).truncate
    puts "number of rooms: #{theoretical_number_of_rooms}"
    @rooms = Array.new(@room_dimensions){Array.new(@room_dimensions)}

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
    midpoint = @room_dimensions.div 2
    @rooms[midpoint][midpoint] = Room.new
    puts @rooms
  end
end
