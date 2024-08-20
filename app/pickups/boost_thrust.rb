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

  def initialize(
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

    collate_sprites 'boost'
    set_scale scale

    @x = x
    @y = y
    @bounce = bounce

    @amount = amount
    @duration = duration
    @start_duration = start_duration

    @sound_pickup_success = "sounds/pickup.wav"
    @sound_bounce = "sounds/thump.wav"

    puts @sprite_scale_hash
    puts "\n\n#{@current_sprite_hash}"
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
