class BaseGame < Zif::Game
  include Zif::Traceable

  def initialize
    super()

    @tracer_service_name = :tracer

    $SPRITE_SCALES = {
      large: 64,
      medium: 32,
      small: 16
    }.freeze

    $LABEL_STYLE = {
      r: 0,
      g: 0,
      b: 255,
      size_px: 14
    }.freeze

    $BACKGROUND_STYLE = {
      r: 0,
      g: 255,
      b: 0,
      a: 128,
      path: :solid
    }.freeze

    $ui_viewscreen_border = 40
    $ui_viewscreen_dimensions = 640
    $ui_viewscreen = {
      top: 1280 - 80,
      right: 720 - $ui_viewscreen_border,
      bottom: 1280 - 80 - $ui_viewscreen_dimensions,
      left: $ui_viewscreen_border
    }

    @services.register(:effect_service, Services::EffectService.new)
    @services.register(:tick_service, Services::TickService.new)

    register_scene(:room, RoomScene)
    register_scene(:game_over, GameOverScene)

    @scene = SplashScene.new
    # @scene = RoomScene.new
  end
end
