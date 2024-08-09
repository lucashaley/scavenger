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

    # @room_dimensions = room_dimensions

    @entrypoint = Room.new(name: 'entrypoint', scale: :large)
    switch_rooms @entrypoint

    # UI Progress bar
    @deterioration_progress = ExampleApp::ProgressBar.new(:count_progress, 440, 0, :white)
    @deterioration_progress.x = 720 - 40 - 440 # 360 - (400 * 0.5)
    @deterioration_progress.y = 1220
    @deterioration_progress.view_actual_size!
    # @deterioration_progress.hide
  end

  def switch_rooms room, door=nil
    puts "husk switch_rooms: #{room}, #{door}"
    @current_room.deactivate unless @current_room.nil?
    @current_room = room
    @current_room.activate

    # gotta be a better way
    # Look into create a scaleable service
    puts "setting scale from husk: #{room.scale}"
    $game.scene.ship.set_scale room.scale
    # door.exit_door $game.scene.ship unless door.nil?
    $game.scene.ship.assign(door.exit_point) unless door.nil?
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
