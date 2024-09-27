module HuskGame
  class BoostThrust < Pickup
    attr_reader :amount, :duration, :start_duration

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }

    SPRITE_DETAILS = {
      name: "boostthrust",
      layers: [
        {
          name: "main",
          blendmode_enum: :alpha,
          z: 1
        },
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: -1
        }
      ],
      scales: {
        large: {
          w: 64,
          h: 64
        },
        medium: {
          w: 32,
          h: 32
        },
        small: {
          w: 16,
          h: 16
        }
      }
    }.freeze

    def initialize(
      x: 0,
      y: 0,
      # bounce: 0.8,
      amount: 10,
      duration: 3.seconds,
      start_duration: 10,
      scale: :large
    )
      super(x: x, y: y, scale: scale)

      @amount = amount
      @duration = duration
      @start_duration = start_duration
    end

    def perform_pickup collidee
      puts "BoostThrust perform_pickup"
      collidee.boost_thrust @amount, @duration, @start_duration
    end
  end
end
