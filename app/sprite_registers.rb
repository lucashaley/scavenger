module SpriteRegisters
  def register_all_sprites
    puts "\nRegistering all sprites"
    puts "=======================\n\n"

    $services[:sprite_registry].register_basic_sprite(
      :ship_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :wall_16,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :wall2_08,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :doorh_128,
      width: 128,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :doorv_128,
      width: 64,
      height: 128
    )
    $services[:sprite_registry].register_basic_sprite(
      :pickup_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :mine_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :effector_64,
      width: 64,
      height: 64
    )

    $services[:sprite_registry].register_basic_sprite(
      :ship_32,
      width: 32,
      height: 32
    )

    $services[:sprite_registry].register_basic_sprite(
      :light,
      width: 1280,
      height: 1280
    )
  end
end
