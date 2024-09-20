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

  SPRITE_DETAILS = {
    name: "wall",
    layers: [
      {
        name: "main",
        blendmode_enum: :alpha,
        z: 1
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }

  def initialize (
    x=0,
    y=0,
    bounce=0.8,
    facing = :north,
    scale = :large
  )
    super(Zif.unique_name("Wall#{facing.to_s}"))

    set_position(x, y)

    # wall_type = 'wall' + facing.to_s
    SPRITE_DETAILS.name = 'wall' + facing.to_s
    register_sprites_new

    # collate_sprites wall_type
    # set_scale scale
    initialize_scaleable(scale)
    initialize_collideable
    initialize_bounceable(bounce: bounce)
  end

  def collide_action collidee, facing
    # puts "Colliding with wall!"
    # play_once @sound_bounce
    bounce_off(collidee, facing)
  end

  def bounce
    # puts "bounce: #{@scale}"
    # puts "bounce: #{BOUNCE_SCALES[@scale]}"
    BOUNCE_SCALES[@scale]
  end
end
