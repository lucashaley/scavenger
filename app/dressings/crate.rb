module HuskGame
  class Crate < Dressing

    sprite_data 'crate'

    def initialize(
      x: 360,
      y: 900,
      scale: :large
    )
      super(x: x, y: y, scale: scale)

      @sound_collide = HuskGame::AssetPaths::Audio::THUMP

      self
    end
  end
end