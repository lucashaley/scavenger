module Collideable
  include Bounceable
  include Soundable

  attr_reader :collision_rect
  attr_accessor :sound_collide
  attr_accessor :pickup

  def initialize_collision
    @collision_rect = {
      x: 0,
      y: 0,
      h: @h,
      w: @w
    }
  end

  def collision
    puts "Collideable: collision"
    {
      x: @collision_rect[x] + @x,
      y: @collision_rect[y] + @y,
      h: @h,
      w: @w
    }
  end

  def collide_x_with c
    # puts 'Collideable collide_x_with'

    # if !@pickup
    #   puts "Not a pickup"
    #   # play_once @sound_collide
    #   bounce_x_off c
    #   # collide_action c
    #   return
    # end
    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door

    collided_on = :west if c.x < @x
    collided_on = :east if c.x > @x

    collide_action c, collided_on

    # if (c.x < @x && c.facing == :east) || (c.x > @x && c.facing == :west)
    #   puts "YUSSSSS"
    #   play_once @sound_pickup_success
    #   pickup_action c, collided_on
    # else
    #   # play_once @sound_pickup_failure
    #   bounce_x_off c, collided_on
    # end
  end

  def collide_y_with c
    # puts "Collideable #{@name}: collide_y_with"

    # if !@pickup
    #   play_once @sound_collide
    #   collide_action c
    #   return
    # end
    #
    # puts 'We didn\'t break all the way'
    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door

    collided_on = :south if c.y < @y
    collided_on = :north if c.y > @y

    collide_action c, collided_on

    # if c.y < @y && c.facing == :north
    #   puts 'pickup south'
    #   play_once @sound_pickup_success
    #   pickup_action c
    # # elsif c.y > @y && c.angle.abs == 180
    # elsif c.y > @y && c.facing == :south
    #   # We're being hit on the north side
    #   puts 'pickup north'
    #   play_once @sound_pickup_success
    #   pickup_action c
    # else
    #   # play_once @sound_pickup_failure
    #   bounce_y_off c
    # end
  end
end
