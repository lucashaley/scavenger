module HuskGame
  class BaseGame < Zif::Game
    include Zif::Traceable

    def initialize
      super()

      @tracer_service_name = :tracer

      # Set up global constants for backward compatibility
      # TODO: Refactor code to use HuskGame::Constants directly instead of globals
      $SPRITE_SCALES = HuskGame::Constants::SPRITE_SCALES
      $LABEL_STYLE = HuskGame::Constants::LABEL_STYLE
      $BACKGROUND_STYLE = HuskGame::Constants::BACKGROUND_STYLE
      $ui_viewscreen_border = HuskGame::Constants::VIEWSCREEN_BORDER
      $ui_viewscreen_dimensions = HuskGame::Constants::VIEWSCREEN_SIZE
      $ui_viewscreen = HuskGame::Constants::VIEWSCREEN

      @services.register(:effect_service, Services::EffectService.new)
      @services.register(:tick_service, Services::TickService.new)
      @services.register(:emp_service, Services::EmpService.new)
      @services.register(:spatial_grid, Services::SpatialGridService.new(cell_size: 128))
      @services.register(:sprite_data_loader, Services::SpriteDataLoader.new)

      register_scene(:menu_main, MenuMainScene)
      register_scene(:room, RoomScene)
      register_scene(:game_over, GameOverScene)
      register_scene(:game_complete, GameCompleteScene)
      register_scene(:menu_about, AboutScene)

      @scene = SplashScene.new
      # @scene = RoomScene.new
    end
  end
end