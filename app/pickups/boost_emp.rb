module HuskGame
  class BoostEmp < Pickup

    sprite_data 'boostemp'

    def perform_pickup(collidee)
      collidee.emp_count += 1
    end
  end
end
