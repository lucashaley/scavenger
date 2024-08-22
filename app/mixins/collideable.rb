module Collideable
  include Bounceable
  include Soundable

  # attr_accessor :collision_rect
  attr_accessor :collision_enabled
  attr_accessor :sound_collide
  # attr_accessor :pickup

  def initialize_collideable(
    sound_collide: ''
  )
    @collision_enabled = true
    @sound_collide = sound_collide
  end

  def set_collision_scale (scale=:large)
    puts "set_collision_scale #{name}: #{scale}"
    @h = collision_scales(scale)
    @w = collision_scales(scale)
  end

  def collide_x_with (c)
    return unless @collision_enabled

    play_once @sound_collide unless @sound_collide.nil?

    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door

    collided_on = :west if c.x < @x
    collided_on = :east if c.x > @x

    collide_action c, collided_on
  end

  def collide_y_with (c)
    return unless @collision_enabled

    play_once @sound_collide unless @sound_collide.nil?

    # puts 'We didn\'t break all the way'
    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door

    collided_on = :south if c.y < @y
    collided_on = :north if c.y > @y

    collide_action c, collided_on
  end
end
