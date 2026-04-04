module HuskGame
class Cable01 < HuskSprite
  include HuskEngine::Scaleable

  sprite_data 'cable01'

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