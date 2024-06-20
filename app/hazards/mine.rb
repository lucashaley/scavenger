class Mine < Zif::Sprite
  include Collideable
  include Deadable

  def initialize(
    prototype,
    x=0, y=0,
    bounce=0.8
  )
    puts 'New Mine!'
    super()
    assign(prototype.to_h)

    @x = x
    @y = y

    @sound_collide = "sounds/thump.wav"
  end

  def collide_action collidee, facing
    puts 'collide_action'
    collidee.health_thrust *= 0.5
    collidee.health_ccw *= 0.3
    kill
  end
end
