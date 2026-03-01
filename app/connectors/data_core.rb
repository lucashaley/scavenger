module HuskGame
  class DataCore < Connector

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }.freeze

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('datacore')
    end

    def indicator_layer_name
      "network"
    end

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