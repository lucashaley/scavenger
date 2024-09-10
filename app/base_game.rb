class BaseGame < Zif::Game
  def initialize
    super()

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

    @services.register(:effect_service, Services::EffectService.new)

    # register_scene(:movement, MovementScene)
    register_scene(:game_over, GameOverScene)

    # @scene = MovementScene.new
    # @scene = EnvironmentScene.new
    @scene = RoomScene.new
  end
end
