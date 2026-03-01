module HuskGame
  class DataTerminal < Connector

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }.freeze

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('dataterminal')
    end

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