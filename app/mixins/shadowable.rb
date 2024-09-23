module Shadowable

  SHADOW_SCALE_OFFSETS = {
    large: 8,
    medium: 6,
    small: 4
  }
  SHADOW_CENTER_OFFSETS = {
    large: 3,
    medium: 2,
    small: 2
  }
  def initialize_shadowable
    $services[:sprite_registry].alias_sprite(
      "shadow_large",
      "#{self.class.name.downcase}_shadow_large".to_sym
    )
    $services[:sprite_registry].alias_sprite(
      "shadow_medium",
      "#{self.class.name.downcase}_shadow_medium".to_sym
    )
    $services[:sprite_registry].alias_sprite(
      "shadow_small",
      "#{self.class.name.downcase}_shadow_small".to_sym
    )

    raise StandardError "Shadow didn't register" unless $services[:sprite_registry].sprite_registered?("#{self.class.name.downcase}_shadow_large".to_sym)

    # Check to see if Tickable is already registered
    # TODO this later
    # $game.services[:tick_service].register_tickable self unless $game.services[:tick_service].tick_registered? self
  end

  def perform_shadow_tick
    # puts "SHADOW TICK: #{@name}"
    # shadow_offset = 4
    shadow_offset = SHADOW_SCALE_OFFSETS[@scale]

    diff_array = Zif.sub_positions($gtk.args.state.ship.xy, self.xy)
    diff_normalized = $gtk.args.geometry.vec2_normalize({
      x: diff_array[0],
      y: diff_array[1]
    })
    diff_scaled = diff_normalized.merge(diff_normalized) {|k,v| -v * shadow_offset }
    # diff_scaled = diff_normalized.merge(diff_normalized) {|k,v| -v }

    shadow = @sprites.find { |s| s.name == "#{self.class.name.downcase}_shadow_#{scale}" }
    shadow.assign(
      {
        x: diff_scaled[:x] - SHADOW_CENTER_OFFSETS[@scale],
        y: diff_scaled[:y] - SHADOW_CENTER_OFFSETS[@scale]
      }
    )
  end
end