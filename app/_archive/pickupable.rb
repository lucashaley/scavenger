# This module is a bit redundant, as functionality has moved to Collideable

module Pickupable
  include HuskEngine::Bounceable
  include Soundable

  attr_accessor :sound_pickup_success
  # @sound_pickup_failure

  def collide_x_with c
    puts 'pickup collide_x_with'

    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door

    # if (c.x < @x && c.angle == -90) || (c.x > @x && c.angle == 90)
    if (c.x < @x && c.facing == :east) || (c.x > @x && c.facing == :west)
      puts "YUSSSSS"
      play_once @sound_pickup_success
      pickup_action c
      @dead = true
    else
      # play_once @sound_pickup_failure
      bounce_x_off c
    end
  end
  def collide_y_with c
    puts 'pickup collide_y_with'

    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door
    puts "y: #{c.y}, angle: #{c.angle}"
    # if c.y < @y && c.angle.remainder_of_divide(360) == 0 # considering -360, etc
    if c.y < @y && c.facing == :north
      puts 'pickup south'
      play_once @sound_pickup_success
      pickup_action c
      @dead = true
    # elsif c.y > @y && c.angle.abs == 180
    elsif c.y > @y && c.angle.abs == :south
      # We're being hit on the north side
      puts 'pickup north'
      play_once @sound_pickup_success
      pickup_action c
      @dead = true
    else
      # play_once @sound_pickup_failure
      bounce_y_off c
    end
  end
end
