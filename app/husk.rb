module HuskGame
  class Husk
    include HuskEngine::Soundable

    attr_reader :health, :deterioration_rate, :deterioration_progress
    attr_reader :current_room, :visited_rooms, :layout
    attr_accessor :data_core, :breach  # written by RoomPopulator
    attr_accessor :all_unlocked, :unlock_terminal  # written by UnlockTerminal
    attr_accessor :has_locked_doors  # set by RoomPopulator when locked doors are created

    DETERIORATION_SCALE = 0.000001

    HEALTH_WARNING_THRESHOLDS = {
      first:  0.4,
      second: 0.3,
      third:  0.2,
      fourth: 0.1
    }.freeze

    def initialize(initial_chaos: 0, initial_threat: 0)
      @health = 1.0
      @deterioration_rate = 100 * DETERIORATION_SCALE
      @data_core = nil
      @all_unlocked = false
      @unlock_terminal = nil
      @has_locked_doors = false
      @visited_rooms = []

      # Phase 1: Generate the full husk layout (graph only, no Room objects)
      @layout = HuskLayout.new(initial_chaos: initial_chaos, initial_threat: initial_threat)
      @rooms = {}  # node_id => Room (lazily populated)

      # Phase 2: Build the breach room from the layout
      @breach = nil
      @entrypoint = build_room_from_node(@layout.breach_node_id)
      switch_rooms @entrypoint

      # UI Progress bar
      bar_w = HuskGame::Constants::PROGRESS_BAR_WIDTH
      @deterioration_progress = ExampleApp::ProgressBar.new(:count_progress, bar_w, 0, :white)
      @deterioration_progress.x = HuskGame::Constants::SCREEN_WIDTH - HuskGame::Constants::VIEWSCREEN_BORDER - bar_w
      @deterioration_progress.y = HuskGame::Constants::PROGRESS_BAR_Y_HUSK
      @deterioration_progress.view_actual_size!

      @warning = :none
    end

    # Lazily create a Room from a layout node. Returns existing Room if already built.
    def room_for_node(node_id, entrance_side: nil)
      return @rooms[node_id] if @rooms[node_id]
      build_room_from_node(node_id, entrance_side: entrance_side)
    end

    def switch_rooms(room, door = nil)
      @current_room.deactivate unless @current_room.nil?
      @current_room = room
      @current_room.activate
      @visited_rooms << room unless @visited_rooms.include?(room)

      if $game.scene.is_a? RoomScene
        $game.scene.fade_in(0.2.seconds)
      end

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

    def damage(amount)
      @deterioration_rate += amount.clamp(0, 100) * DETERIORATION_SCALE
    end

    def rooms_visited
      @visited_rooms.length
    end

    def rooms_discovered
      @layout.total_rooms
    end

    def serialize
      {
        health: @health,
        current_room: @current_room,
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    private

    def build_room_from_node(node_id, entrance_side: nil)
      node = @layout.node(node_id)
      return nil unless node

      room = Room.new(
        name:          node[:name],
        scale:         node[:scale],
        husk:          self,
        chaos:         node[:chaos],
        threat:        node[:threat],
        node:          node,
        entrance_side: entrance_side
      )
      @rooms[node_id] = room
      room
    end
  end
end
