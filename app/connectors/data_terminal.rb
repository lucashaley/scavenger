module HuskGame
  # class DataTerminal < Zif::CompoundSprite
  #   include Zif::Traceable
  #   include HuskEngine::Collideable
  #   include HuskEngine::Bounceable
  #   include HuskEngine::Scaleable
  #   include HuskEngine::Faceable
  #   include HuskEngine::Bufferable
  #   include HuskEngine::Spatializeable
  #   include HuskEngine::Tickable
  #   include HuskEngine::Shadowable
  #
  #
  #   attr_reader :interfacing, :data, :data_rate, :tolerance
  #   attr_accessor :audio_idle
  class DataTerminal < Connector

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }.freeze

    SPRITE_DETAILS = {
      name: "dataterminal",
      layers: [
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: -1
        },
        {
          name: "main",
          blendmode_enum: :alpha,
          z: 1
        },
        {
          name: "lights",
          blendmode_enum: :add,
          z: 2
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
    }.freeze

    def initialize(
      x: 0,
      y: 0,
      scale: :large,
      facing: :south,
      tolerance: 4,
      data: 1000,
      data_rate: 2
    )
      super(x: x, y: y, scale: scale, facing: facing, tolerance: tolerance)
    end
  end
end