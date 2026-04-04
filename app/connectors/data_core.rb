module HuskGame
  class DataCore < Connector

    sprite_data 'datacore'

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