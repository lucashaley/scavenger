module HuskGame
  class CrateBig < Dressing

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('cratebig')
    end

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