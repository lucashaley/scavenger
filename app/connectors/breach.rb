class Breach < Zif::CompoundSprite
  include HuskEngine::Collideable
  include HuskEngine::Bounceable
  include HuskEngine::Scaleable
  include HuskEngine::Bufferable
  include HuskEngine::Spatializeable

  SPRITE_DETAILS = {
    name: "breach",
    layers: [
      {
        name: "base",
        blendmode_enum: :alpha,
        z: 0
      },
      {
        name: "main",
        blendmode_enum: :alpha,
        z: 1
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

  def initialize
    super(Zif.unique_name('Breach'))

    x = 40 + (640 - 64).half
    y = 1280 - 48 - 64 - 640.half
    set_position(x, y)

    # Temporary force
    register_sprites_new
    initialize_scaleable(:large)

    initialize_bufferable(:triple)

    center_sprites
  end

  def self.register_sprites
    # puts "Breach: Registering Sprites"
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_main_large",
    #   width: 64,
    #   height: 64
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_main_large",
    #   :breach_main_large
    # )
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_main_medium",
    #   width: 32,
    #   height: 32
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_main_medium",
    #   :breach_main_medium
    # )
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_main_small",
    #   width: 16,
    #   height: 16
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_main_small",
    #   :breach_main_small
    # )
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_base_large",
    #   width: 76,
    #   height: 76
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_base_large",
    #   :breach_base_large
    # )
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_base_medium",
    #   width: 36,
    #   height: 36
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_base_medium",
    #   :breach_base_medium
    # )
    #
    # $services[:sprite_registry].register_basic_sprite(
    #   "breach/breach_base_small",
    #   width: 20,
    #   height: 20
    # )
    # $services[:sprite_registry].alias_sprite(
    #   "breach/breach_base_small",
    #   :breach_base_small
    # )
  end
end