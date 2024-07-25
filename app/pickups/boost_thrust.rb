class BoostThrust < Zif::CompoundSprite
  # include Pickupable
  include Collideable
  include Deadable
  include Bounceable
  include Scaleable

  attr_reader :amount, :duration, :start_duration

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }
  SPRITE_SCALES = {
    large: 64,
    medium: 32,
    small: 16
  }
  def sprite_scales scale
    SPRITE_SCALES[scale]
  end
  # COLLISION_SCALES = {
  #   large: 64,
  #   medium: 32,
  #   small: 16
  # }
  # def collision_scales scale
  #   puts "Setting collision scale for #{name}: #{scale}"
  #   COLLISION_SCALES[scale]
  # end

  def initialize(
    prototype,
    x=0,
    y=0,
    bounce=0.8,
    amount=10,
    duration=3.seconds,
    start_duration=10,
    scale=:large
  )
    puts "\n\nBoostThrust Initialize\n======================"
    super()
    # assign(prototype.to_h)

    # Assemble the sprites from the naming convention
    # Class
    # Type
    # Section
    # Scale
    # pickup_boost_main_large
    # pickup_boost_vfx_large

    @scale = scale
    collate_sprites 'boost'

    @x = x
    @y = y
    @bounce = bounce

    @amount = amount
    @duration = duration
    @start_duration = start_duration

    @sound_pickup_success = "sounds/pickup.wav"
    @sound_bounce = "sounds/thump.wav"

    set_scale scale
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
end
