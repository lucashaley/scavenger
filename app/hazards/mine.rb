class Mine < Zif::Sprite
  include Collideable
  include Deadable

  def initialize(
    prototype,
    x=0, y=0,
    bounce=0.8
  )
    super()
    assign(prototype.to_h)

    @x = x
    @y = y

    # initialize_collision
    @sound_collide = "sounds/thump.wav"
  end

  def collide_action collidee, facing
    puts 'collide_action'
    damage = 0.4
    # collidee.health_thrust *= 0.5
    # collidee.health_ccw *= 0.3
    case facing
    when :north
      collidee.health_north *= damage
      collidee.momentum.y += 4
    when :south
      collidee.health_south *= damage
      collidee.momentum.y += -4
    when :east
      collidee.health_east *= damage
      collidee.momentum.x += 4
    when :west
      collidee.health_west *= damage
      collidee.momentum.x += -4
    end

    # Damage the husk
    $game.scene.husk.damage 60
    # And get rid of the mine
    kill
  end
end
