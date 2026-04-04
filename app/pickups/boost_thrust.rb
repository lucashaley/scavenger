module HuskGame
  class BoostThrust < Pickup
    attr_reader :amount, :duration, :start_duration

    sprite_data 'boostthrust'

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
