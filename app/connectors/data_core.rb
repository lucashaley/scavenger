module HuskGame
  class DataCore < Connector
    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }.freeze

    SPRITE_DETAILS = {
      name: "datacore",
      layers: [
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: 1
        },
        {
          name: "main",
          blendmode_enum: :alpha,
          z: 2
        },
        {
          name: "network",
          blendmode_enum: :alpha,
          z: 0
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
    }.freeze

    def initialize(
      x: 0,
      y: 0,
      scale: :large,
      tolerance: 4,
      data: 1000,
      data_rate: 2
    )
      super(x: x, y: y, scale: scale, tolerance: tolerance)
      puts "INIT DATACORE\n============="

      rotate_sprites([:north, :south, :east, :west].sample)
    end
  end
end