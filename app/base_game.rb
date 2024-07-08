class BaseGame < Zif::Game
  def initialize
    super()
    @services.register(:effect_service, Services::EffectService.new)

    # register_scene(:movement, MovementScene)
    register_scene(:game_over, GameOverScene)

    # @scene = MovementScene.new
    # @scene = EnvironmentScene.new
    @scene = RoomScene.new
  end
end
