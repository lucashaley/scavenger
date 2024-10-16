# frozen_string_literal: true

module HuskGame
  module FragmentShip
    @ship = $gtk.args.state.ship

    def handle_ship
      $gtk.args.state.ship ||= {

      }
    end

    def ship_add_thrust_y(input)
      health_multiplier = input < 0 ? @health_south : @health_north
      @energy.y += input * @thrust * health_multiplier * SCALED_THRUST[@scale]
    end
  end
end