module HuskGame
  class Crate < Dressing
    SPRITE_DETAILS = {
      name: "crate",
      layers: [
        {
          name: "main",
          blendmode_enum: BLENDMODE[:alpha],
          z: 0
        },
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: -1
        }
      ],
      scales: {
        large: {
          w: 64,
          h: 64
        },
        medium: {
          w: 32,
          h: 32
        },
        small: {
          w: 16,
          h: 16
        }
      }
    }

    def initialize(
      x: 360,
      y: 900,
      scale: :large
    )
      super(x: x, y: y, scale: scale)

      @sound_collide = "sounds/thump.wav"

      self
    end
  end
end