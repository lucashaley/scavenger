module HuskGame
  class StaticBlob < HuskSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Empable
    include HuskEngine::Stateable

    sprite_data 'hunterblob'

    EMP_LOW = 60
    EMP_MEDIUM = 120

    def initialize(
      x: 360,
      y: 960,
      scale: :large
    )
      @tracer_service_name = :tracer
      super(Zif.unique_name("StaticBlob"))

      set_position(x, y)
      initialize_deadable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bufferable(:single)
      initialize_tickable
      initialize_stateable("agent")

      initialize_empable
      @emp_low = EMP_LOW
      @emp_medium = EMP_MEDIUM

      @sound_collide = HuskGame::AssetPaths::Audio::THUMP
      @audio_idle = HuskGame::AssetPaths::Audio::HUNTER_BLOB_IDLE
    end

    def perform_tick
      return unless @active

      spatialize(@name.to_sym)
    end

    def collide_action(collidee, facing)
      collidee.add_data_block(name: 'staticblob', size: 1, corrupted: true)
      kill
    end

    def bounce
      0
    end

    def handle_emp_low(emp_level)
    end

    def handle_emp_medium(emp_level)
      kill
    end

    def handle_emp_high(emp_level)
      kill
    end
  end
end
