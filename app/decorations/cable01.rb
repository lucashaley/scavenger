module HuskGame
class Cable01 < Zif::CompoundSprite
  include HuskEngine::Scaleable

  SPRITE_DETAILS = {
    name: "cable01",
    layers: [
      {
        name: "main",
        blendmode_enum: :alpha,
        z: 0
      }
    ],
    scales: {
      large: {
        w: 128,
        h: 128
      },
      # medium: {
      #   w: 32,
      #   h: 32
      # },
      # small: {
      #   w: 16,
      #   h: 16
      # }
    }
  }.freeze

  def initialize(
    x: 360,
    y: 900,
    scale: :large
  )
    super(Zif.unique_name("Cable01"))

    set_position(x, y)
    register_sprites_new
    initialize_scaleable(scale)

    rotate_sprites([0, 90, 180, 270].sample)
  end
end
end