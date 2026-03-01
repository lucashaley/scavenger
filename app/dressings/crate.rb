module HuskGame
  class Crate < Dressing

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('crate')
    end

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