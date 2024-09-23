# frozen_string_literal: true

class Crate < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Bufferable
  include Shadowable
  include Tickable
  include Zif::Traceable

  SPRITE_DETAILS = {
    name: "crate",
    layers: [
      {
        name: "main",
        blendmode_enum: BLENDMODE[:alpha],
        z: 0
      },
      {
        name: "shadow",
        blendmode_enum: BLENDMODE[:multiply],
        z: -1
      }
    ],
    scales: [
      :large,
      :medium,
      :small
    ]
  }

  def initialize(
    x: 360,
    y: 900,
    scale: :large
  )
    @tracer_service_name = :tracer
    super(Zif.unique_name("Crate"))
    # puts "crate: initialize"

    @sound_collide = "sounds/thump.wav"

    set_position(x, y)

    initialize_shadowable
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_bounceable
    initialize_bufferable(:single)
    initialize_tickable

    # puts "crate: initialized"
  end

  def collide_action collidee, facing
    mark_and_print("collide_action: #{collidee.name}, #{facing}")
    play_once @sound_collide
    bounce_off(collidee, facing)
  end

  def perform_tick
    perform_shadow_tick
  end

  def is_dead?
    false
  end
end
