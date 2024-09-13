class Breach < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Bufferable
  include Spatializeable

  SPRITE_DETAILS = {
    name: "breach",
    layers: [
      {
        name: "main",
        blendmode_enum: :alpha
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  def self.register_sprites
    puts "Breach: Registering Sprites"

    $services[:sprite_registry].register_basic_sprite(
      "breach/breach_main_large",
      width: 64,
      height: 64
    )
    $services[:sprite_registry].alias_sprite(
      "breach/breach_main_large",
      :breach_main_large
    )

    $services[:sprite_registry].register_basic_sprite(
      "breach/breach_main_medium",
      width: 32,
      height: 32
    )
    $services[:sprite_registry].alias_sprite(
      "breach/breach_main_medium",
      :breach_main_medium
    )

    $services[:sprite_registry].register_basic_sprite(
      "breach/breach_main_small",
      width: 16,
      height: 16
    )
    $services[:sprite_registry].alias_sprite(
      "breach/breach_main_small",
      :breach_main_small
    )
  end

  def initialize
    super(Zif.unique_name('Breach'))

    puts "\n\nBREACH\n======\n\n"

    x = 40 + (640 - 64).half
    y = 1280 - 48 - 64 - 640.half
    set_position(x, y)

    # Temporary force
    initialize_scaleable(:large)

    initialize_bufferable(:triple)
  end
end