module SpriteRegisters
  def register_all_sprites
    puts "\nRegistering all sprites"
    puts "=======================\n\n"

    # Ship.register_sprites
    # BoostThrust.register_sprites
    # DataTerminal.register_sprites
    # Door.register_sprites
    # Mine.register_sprites
    # Attractor.register_sprites
    # Repulsor.register_sprites
    # Breach.register_sprites

    $services[:sprite_registry].register_basic_sprite(
      :ui_button_large_up,
      width: 128,
      height: 128
    )
    $services[:sprite_registry].register_basic_sprite(
      :ui_button_large_down,
      width: 128,
      height: 128
    )
    $services[:sprite_registry].register_basic_sprite(
      :ui_button_rotate_up,
      width: 128,
      height: 128
    )
    $services[:sprite_registry].register_basic_sprite(
      :ui_button_rotate_down,
      width: 128,
      height: 128
    )

    $services[:sprite_registry].register_basic_sprite(
      :light,
      width: 1280,
      height: 1280
    )

    # GENERIC SHADOW
    $services[:sprite_registry].register_basic_sprite(
      "shadow_large",
      width: 70,
      height: 70
    )
    $services[:sprite_registry].register_basic_sprite(
      "shadow_medium",
      width: 46,
      height: 46
    )
    $services[:sprite_registry].register_basic_sprite(
      "shadow_small",
      width: 36,
      height: 36
    )
    $services[:sprite_registry].register_basic_sprite(
      "shadow_tiny",
      width: 20,
      height: 20
    )
  end
end
