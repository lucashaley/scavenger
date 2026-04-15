module HuskGame
  class BaseGame < Zif::Game
    include Zif::Traceable

    def initialize
      super()

      @tracer_service_name = :tracer

      @services.register(:effect_service, Services::EffectService.new)
      @services.register(:tick_service, Services::TickService.new)
      @services.register(:emp_service, Services::EmpService.new)
      @services.register(:spatial_grid, Services::SpatialGridService.new(cell_size: 128))
      @services.register(:sprite_data_loader, Services::SpriteDataLoader.new)
      @services.register(:particle_service, Services::ParticleService.new)

      register_scene(:menu_main, MenuMainScene)
      register_scene(:husk_select, HuskSelectScene)
      register_scene(:room, RoomScene)
      register_scene(:game_over, GameOverScene)
      register_scene(:game_complete, GameCompleteScene)
      register_scene(:menu_about, AboutScene)

      @scene = SplashScene.new
      # @scene = RoomScene.new
    end
  end
end