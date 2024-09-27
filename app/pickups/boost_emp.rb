module HuskGame
  class BoostEmp < Pickup
    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1
    }

    SPRITE_DETAILS = {
      name: "boostemp",
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

    def perform_pickup(collidee)
      collidee.emp_count += 1
    end
  end
end
