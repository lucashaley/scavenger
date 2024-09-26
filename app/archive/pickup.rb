## This class is pretty much useless
# All functionality has been shifted to the Pickupable mixin

class Pickup < Zif::Sprite
  include HuskEngine::Bounceable
  include Deadable
  include Soundable

  def initialize (
    prototype,
    x=0,
    y=0,
    bounce=0.8
  )
    super()
    assign(prototype.to_h)

    @x = x
    @y = y
    @bounce = bounce
    @sound_bounce = "sounds/thump.wav"
  end

  def collide_x_with c
    puts 'pickup collide_x_with'
    # First we need to know which side we're being hit on
    # and then the direction the ship is facing
    # It would be nice to limit the collision to a smaller size from center
    # like with the door
    if (c.x < @x && c.angle == -90) || (c.x > @x && c.angle == 90) # This doesn't accomodate -270, etc
      puts "YUSSSSS"
      play_once "sounds/pickup.wav"
      c.boost_thrust
      self.kill
    else
      play_once "sounds/thump.wav"
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
    if c.y < @y && c.angle.remainder_of_divide(360) == 0 # considering -360, etc
      puts 'pickup south'
      play_once "sounds/pickup.wav"
      c.boost_thrust
      self.kill
    elsif c.y > @y && c.angle.abs == 180
      # We're being hit on the north side
      puts 'pickup north'
      play_once "sounds/pickup.wav"
      c.boost_thrust
      self.kill
    else
      play_once "sounds/thump.wav"
      bounce_y_off c
    end
  end
end
