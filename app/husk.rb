module HuskGame
  class Husk
    include HuskEngine::Soundable

    attr_reader :health, :deterioration_rate, :deterioration_progress
    attr_reader :current_room
    attr_accessor :data_core, :breach  # written by RoomPopulator
    attr_accessor :all_unlocked, :unlock_terminal  # written by UnlockTerminal
    attr_accessor :has_locked_doors  # set by RoomPopulator when locked doors are created

    DOORS = {
      north:  1,
      east:   2,
      south:  4,
      west:   8
    }

    DETERIORATION_SCALE = 0.000001

    HEALTH_WARNING_THRESHOLDS = {
      first:  0.4,
      second: 0.3,
      third:  0.2,
      fourth: 0.1
    }.freeze

    def initialize(initial_chaos: 0, initial_threat: 0)
      # Variables
      @health = 1.0
      @deterioration_rate = 100 * DETERIORATION_SCALE
      @data_core = nil
      @all_unlocked = false
      @unlock_terminal = nil
      @has_locked_doors = false

      @breach = nil
      @entrypoint = Room.new(name: 'entrypoint', scale: :large, husk: self, chaos: initial_chaos, threat: initial_threat)
      switch_rooms @entrypoint

      # UI Progress bar
      bar_w = HuskGame::Constants::PROGRESS_BAR_WIDTH
      @deterioration_progress = ExampleApp::ProgressBar.new(:count_progress, bar_w, 0, :white)
      @deterioration_progress.x = HuskGame::Constants::SCREEN_WIDTH - HuskGame::Constants::VIEWSCREEN_BORDER - bar_w
      @deterioration_progress.y = HuskGame::Constants::PROGRESS_BAR_Y_HUSK
      @deterioration_progress.view_actual_size!
      # @deterioration_progress.hide

      @warning = :none
    end

    def switch_rooms room, door=nil
      # puts "husk switch_rooms: #{room}, #{door}"
      @current_room.deactivate unless @current_room.nil?
      @current_room = room
      @current_room.activate

      if $game.scene.is_a? RoomScene
        $game.scene.fade_in(0.2.seconds)
      end

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

      thresholds = HEALTH_WARNING_THRESHOLDS
      if @health < thresholds[:first] && @warning == :none
        @warning = :once
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_WARNING_HUSK_INTEGRITY)
      end
      if @health < thresholds[:second] && @warning == :once
        @warning = :twice
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_WARNING)
      end
      if @health < thresholds[:third] && @warning == :twice
        @warning = :thrice
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_RETURN_TO_BREACH)
      end
      if @health < thresholds[:fourth] && @warning == :thrice
        @warning = :fourice
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_RETURN_TO_BREACH)
      end
    end

    # I don't like to work with such small values
    # so I'm clamping from 0-100 and scaling here
    def damage amount
      @deterioration_rate += amount.clamp(0, 100) * DETERIORATION_SCALE
    end

    def create_room
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