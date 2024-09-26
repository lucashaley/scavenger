module HuskGame
  class CrateBig < Dressing
    SPRITE_DETAILS = {
      name: "cratebig",
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
          w: 128,
          h: 128
        },
        medium: {
          w: 128,
          h: 128
        },
        small: {
          w: 128,
          h: 128
        }
      }
    }

    def initialize(
      x: 360,
      y: 900,
      scale: :large
    )
      super(x: x, y: y, scale: scale)

      initialize_bufferable(:none)
    end
  end
end