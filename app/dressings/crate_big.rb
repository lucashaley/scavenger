module HuskGame
  class CrateBig < Dressing

    sprite_data 'cratebig'

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