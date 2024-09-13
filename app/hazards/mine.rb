class Mine < Zif::CompoundSprite
  include Collideable
  include Deadable
  include Scaleable
  include Bufferable
  include Spatializeable

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
            frames: 2,
            hold: 10,
            repeat: :forever
          }
        ],
        blendmode_enum: :alpha
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  def self.register_sprites
    puts "Mine: Registering Sprites"

    $services[:sprite_registry].register_basic_sprite(
      "mine/mine_main_large",
      width: 64,
      height: 64
    )
    $services[:sprite_registry].alias_sprite(
      "mine/mine_main_large",
      :mine_main_large
    )
    $services[:sprite_registry].register_basic_sprite(
      "mine/mine_main_medium",
      width: 32,
      height: 32
    )
    $services[:sprite_registry].alias_sprite(
      "mine/mine_main_medium",
      :mine_main_medium
    )
    $services[:sprite_registry].register_basic_sprite(
      "mine/mine_main_small",
      width: 16,
      height: 16
    )
    $services[:sprite_registry].alias_sprite(
      "mine/mine_main_small",
      :mine_main_small
    )
  end

  def initialize(
    x=0,
    y=0,
    scale = :large,
    damage = 0.4
  )
    puts "\n\nMine Initialize\n======================"
    super()

    set_position(x,y)

    # collate_sprites 'mine'
    # set_scale scale
    initialize_scaleable(scale)
    initialize_collideable
    initialize_bufferable(:double)

    @damage = damage

    # initialize_collision
    @sound_collide = "sounds/thump.wav"

    animation_name = "mine_main_#{scale}"
    sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)

    @audio_idle = 'sounds/mine_idle.wav'
  end

  def perform_tick
    super

    # puts "mine tick: #{@active}, #{$gtk.args.audio[@name.to_sym]}"
    #
    # if @active
    #   pan = (self.rect.x - $game.scene.ship.rect.x) * 0.0015625 # 1/640
    #   $gtk.args.audio[@name.to_sym][:x] = pan
    #   $gtk.args.audio[@name.to_sym][:gain] = 1 - pan.abs
    # end

    spatialize(@name.to_sym) if @active
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
