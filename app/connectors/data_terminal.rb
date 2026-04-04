module HuskGame
  class DataTerminal < Connector

    sprite_data 'dataterminal'

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