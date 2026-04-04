module HuskGame
  class BoostData < Pickup

    sprite_data 'boostdata'

    def perform_pickup(collidee)
      collidee.add_data_block_slot
    end
  end
end
