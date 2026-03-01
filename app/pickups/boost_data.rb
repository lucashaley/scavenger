module HuskGame
  class BoostData < Pickup

    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('boostdata')
    end

    def perform_pickup(collidee)
      collidee.add_data_block_slot
    end
  end
end
