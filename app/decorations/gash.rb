module HuskGame
  class Gash < Zif::CompoundSprite
    include HuskEngine::Scaleable

    SPRITE_DETAILS = {
      name: "gash",
      layers: [
        {
          name: "main",
          blendmode_enum: :alpha,
          z: 0
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
      x: 360,
      y: 900,
      scale: :large
    )
      super(Zif.unique_name("Gash"))

      set_position(x, y)
      register_sprites_new
      initialize_scaleable(scale)

      rotate_sprites(rand(360))
    end
  end
end