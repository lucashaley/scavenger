module HuskGame
class Cable01 < HuskSprite
  include HuskEngine::Scaleable

  def self.sprite_details
    @sprite_details ||= $game.services[:sprite_data_loader].load('cable01')
  end

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