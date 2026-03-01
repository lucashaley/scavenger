module HuskGame
  class Gash < HuskSprite
    include HuskEngine::Scaleable

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('gash')
    end

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