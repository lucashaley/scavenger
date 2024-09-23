class Mine < Zif::CompoundSprite
  include Collideable
  include Deadable
  include Scaleable
  include Bufferable
  include Spatializeable
  include Tickable
  include Shadowable

  attr_accessor :damage
  attr_accessor :audio_idle

  SPRITE_DETAILS = {
    name: "mine",
    layers: [
      {
        name: "main",
        animations: [
          {
            name: "idle",
            frames: 3,
            hold: 10,
            repeat: :forever
          },
          {
            name: "blow",
            frames: 7,
            hold: 2,
            repeat: :once
          }
        ],
        blendmode_enum: :add,
        z: 0
      },
      {
        name: "shadow",
        blendmode_enum: BLENDMODE[:multiply],
        z: -1
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  def initialize(
    x=0,
    y=0,
    scale = :large,
    damage = 0.4
  )
    super(Zif.unique_name("Mine"))

    set_position(x,y)

    initialize_shadowable
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    # rotate_sprites([:north, :south, :east, :west].sample)
    initialize_collideable
    initialize_bufferable(:double)
    initialize_tickable

    @damage = damage

    # initialize_collision
    @sound_collide = "sounds/thump.wav"

    animation_name = "mine_main_#{scale}"
    @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)

    @audio_idle = 'sounds/mine_idle.wav'
  end

  def perform_tick
    spatialize(@name.to_sym)
    perform_shadow_tick
  end

  def kill_me
    kill
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

    # play the animation
    animation_name = "mine_main_#{scale}"
    @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:blow)
    # And get rid of the mine
    # kill
  end

  def complete_animation( animation )
    puts "complete_animation"
    case animation
    when :blow
      puts "complete_animation: blow"
      kill
    end
  end
end
