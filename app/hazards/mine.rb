class Mine < Zif::CompoundSprite
  include Collideable
  include Deadable
  include Scaleable
  include Bufferable

  attr_accessor :damage

  def initialize(
    x=0,
    y=0,
    scale = :large,
    damage = 0.4
  )
    puts "\n\nMine Initialize\n======================"
    super()

    collate_sprites 'mine'
    set_scale scale
    initialize_collideable
    initialize_bufferable(:whole)

    @x = x
    @y = y
    @damage = damage

    # initialize_collision
    @sound_collide = "sounds/thump.wav"

    # puts @sprite_scale_hash
    # puts "\n\n#{@current_sprite_hash}"
  end

  def collide_action collidee, facing
    puts 'collide_action'

    case facing
    when :north
      collidee.health_north *= @damage
      collidee.momentum.y += 4
    when :south
      collidee.health_south *= @damage
      collidee.momentum.y += -4
    when :east
      collidee.health_east *= @damage
      collidee.momentum.x += 4
    when :west
      collidee.health_west *= @damage
      collidee.momentum.x += -4
    end

    # Damage the husk
    $game.scene.husk.damage 60
    # And get rid of the mine
    kill
  end
end
