module HuskGame
  class Husk
    attr_accessor :health, :deterioration_rate, :deterioration_progress
    attr_accessor :current_room, :rooms, :room_dimensions, :data_core, :breach

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
      @data_core = nil

      # @room_dimensions = room_dimensions

      @breach = nil
      @entrypoint = Room.new(name: 'entrypoint', scale: :large, husk: self)
      switch_rooms @entrypoint

      # UI Progress bar
      @deterioration_progress = ExampleApp::ProgressBar.new(:count_progress, 440, 0, :white)
      @deterioration_progress.x = 720 - 40 - 440 # 360 - (400 * 0.5)
      @deterioration_progress.y = 1220
      @deterioration_progress.view_actual_size!
      # @deterioration_progress.hide
    end

    def switch_rooms room, door=nil
      # puts "husk switch_rooms: #{room}, #{door}"
      @current_room.deactivate unless @current_room.nil?
      @current_room = room
      @current_room.activate


      # gotta be a better way
      # Look into create a scaleable service
      # puts "setting scale from husk: #{room.scale}"
      # This also causes some headache with having to create the ship
      # before we can create the husk and room
      # $game.scene.ship.set_scale room.scale
      # door.exit_door $game.scene.ship unless door.nil?
      # $gtk.args.state.ship.set_scale room.scale
      $gtk.args.state.ship.switch_rooms room.scale
      door.exit_door $gtk.args.state.ship unless door.nil?
    end

    def calc_health
      @health -= @deterioration_rate
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
      puts "HuskEngine: create_room"
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
end