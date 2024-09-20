module Effectable
  attr_accessor :effect_target
  # attr_accessor :effect_strength
  attr_accessor :effect_active

  def activate_effect
    puts "activate"
    # @effect_strength = 50
    @effect_active = true
  end
  def deactivate_effect
    puts "deactivate"
    # @effect_strength = 0
    @effect_active = false
  end

  def effect_strength
    raise ArgumentError "No effect_strength" if @effect_strength.nil?
    @effect_active ? @effect_strength : 0
  end
end
