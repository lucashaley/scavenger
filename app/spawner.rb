# frozen_string_literal: true
module HuskGame
  class Spawner < HuskSprite
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Tickable
    include HuskGame::Roomable
    include Zif::Traceable

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('crate')
    end

    attr_reader :spawn_class, :rate

    def initialize(
      x: 0,
      y: 0,
      scale: nil,
      spawn_class: nil,
      spawn_rate: 3.seconds,
      room: nil
    )
      # puts "SPAWNER: INITIALIZE: #{spawn_class}"
      super(Zif.unique_name('Spawner'))

      set_position(x, y)
      @spawn_class = spawn_class
      @spawn_rate = spawn_rate

      # initialize_scaleable scale
      @scale = scale
      initialize_roomable room
      initialize_bufferable :single
      initialize_tickable

      @last_spawn = Kernel.tick_count
      # puts "last_spawn: #{@last_spawn}"
    end

    def perform_tick
      current_tick = Kernel.tick_count
      # puts "spawner #{@last_spawn} : #{current_tick} : #{@spawn_rate}"
      if current_tick >= @last_spawn + @spawn_rate
        spawn
        @last_spawn = current_tick
      end
    end

    def spawn
      # puts "SPAWNING!!!\n\n"
      spawn = Object.const_get("HuskGame::#{@spawn_class.to_s}").new(x: @x, y: @y, scale: @scale)
      # puts "Room: #{@room.name}"
      # puts "Spawn: #{spawn}\n\n"
      @room.agents << spawn
      spawn.activate
    end

    # This is a hack
    # TODO: Clean up the is_dead? method and usage in room
    def is_dead?
      false
    end
  end
end