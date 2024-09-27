class Wall < Zif::CompoundSprite
  include HuskEngine::Collideable
  include HuskEngine::Bounceable
  include HuskEngine::Scaleable
  include HuskEngine::Faceable

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
    scales: {
      large: {
        w: 64,
        h: 64
      },
      medium: {
        w: 32,
        h: 32
      },
      small: {
        w: 16,
        h: 16
      }
    }
  }

  def initialize (
    x: 360,
    y: 900,
    # bounce=0.8,
    facing: :north,
    scale: :large
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
    # initialize_bounceable(bounce: bounce)
    initialize_bounceable
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
