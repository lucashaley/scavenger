class BaseGame < Zif::Game
  def initialize
    super()
    @services.register(:effect_service, Services::EffectService.new)

    # register_scene(:movement, MovementScene)

    # @scene = MovementScene.new
    # @scene = EnvironmentScene.new
    @scene = RoomScene.new
  end
end
