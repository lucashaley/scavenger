module HuskEngine
  module Effectable
    attr_accessor :effect_target
    attr_accessor :effect_active

    def activate_effect
      @effect_active = true
    end

    def deactivate_effect
      @effect_active = false
    end

    def effect_strength
      raise ArgumentError "No effect_strength" if @effect_strength.nil?
      @effect_active ? @effect_strength : 0
    end

    # Shared effect calculation. direction: 1 for attract, -1 for repulse.
    def perform_effect
      return unless @effect_active

      effect_vector = $gtk.args.geometry.vec2_normalize({
        x: @x - @effect_target.x,
        y: @y - @effect_target.y
      })

      distance = $gtk.args.geometry.distance self, @effect_target
      effect_vector.x *= (1 / distance) * effect_strength
      effect_vector.y *= (1 / distance) * effect_strength

      @effect_target.effect.x += effect_vector.x * @effect_direction
      @effect_target.effect.y += effect_vector.y * @effect_direction
    end
  end
end