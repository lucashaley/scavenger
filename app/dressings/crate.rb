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
          w: 40,
          h: 40
        },
        small: {
          w: 32,
          h: 32
        },
        tiny: {
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