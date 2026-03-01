module HuskGame
  class BoostEmp < Pickup

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('boostemp')
    end

    def perform_pickup(collidee)
      collidee.emp_count += 1
    end
  end
end
