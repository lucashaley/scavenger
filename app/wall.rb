class Wall < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Faceable

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

  def initialize (
    x=0,
    y=0,
    bounce=0.8,
    facing = :north,
    scale = :large
  )
    super()
    # puts "\n\nWall new: #{x}, #{y}"

    @x = x
    @y = y
    # @bounce = bounce

    @h = 64
    @w = 64

    wall_type = 'wall' + facing.to_s

    collate_sprites wall_type
    set_scale scale
    initialize_collideable
    initialize_bounceable(bounce: bounce)
  end

  def collide_action collidee, facing
    puts "Colliding with wall!"
    # play_once @sound_bounce
    bounce_off(collidee, facing)
  end

  def bounce
    puts "bounce: #{@scale}"
    puts "bounce: #{BOUNCE_SCALES[@scale]}"
    BOUNCE_SCALES[@scale]
  end
end
