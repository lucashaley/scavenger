class BoostThrust < Zif::CompoundSprite
  # include Pickupable
  include Collideable
  include Deadable
  include Bounceable
  include Scaleable
  include Bufferable
  include Tickable
  include Shadowable

  attr_reader :amount, :duration, :start_duration

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }

  SPRITE_DETAILS = {
    name: "boostthrust",
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
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  def initialize(
    x=0,
    y=0,
    bounce=0.8,
    amount=10,
    duration=3.seconds,
    start_duration=10,
    scale=:large
  )
    super(Zif.unique_name("BoostThrust"))

    set_position(x, y)

    # collate_sprites 'boost'
    # set_scale scale
    initialize_shadowable
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    rotate_sprites([:north, :south, :east, :west].sample)
    initialize_collideable(sound_collide: 'sounds/pickup.wav')
    initialize_bounceable(bounce: bounce, sound_bounce: 'sounds/thump.wav')
    initialize_bufferable(:single)
    initialize_tickable

    # @bounce = bounce

    @amount = amount
    @duration = duration
    @start_duration = start_duration

    @sound_pickup_success = "sounds/pickup.wav"
  end

  def collide_action collidee, facing
    puts "collide_action: #{facing}"

    # Get the turret direction from the player
    # and compare it to the collision facing
    if (collidee.facing == :north && facing == :south) ||
    (collidee.facing == :south && facing == :north) ||
    (collidee.facing == :west && facing == :east) ||
    (collidee.facing == :east && facing == :west)
      play_once @sound_pickup_success
      collidee.boost_thrust @amount, @duration, @start_duration
      kill
    else
      play_once @sound_bounce
      bounce_off(collidee, facing)
    end
  end

  def bounce
    puts "bounce: #{BOUNCE_SCALES[@scale]}"
    BOUNCE_SCALES[@scale]
  end

  def perform_tick
    # puts "BoostThrust: perform_tick"
    perform_shadow_tick
  end
end
