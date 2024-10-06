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
        w: 40,
        h: 40
      },
      small: {
        w: 32,
        h: 32
      },
      tiny: {
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

    # Taking this out to try rotating compound sprites
    unless [:north, :south, :east, :west].include? facing
      # puts "CORNER"
      SPRITE_DETAILS.name = 'wallcorner'
    else
      # puts "WALL"
      SPRITE_DETAILS.name = 'wall'
    end
    register_sprites_new

    initialize_scaleable(scale)
    initialize_collideable
    initialize_bounceable

    init_faceable(facing)
    # Walls have corner pieces, unlike everything else
    # So we have to special-check for them
    if [:north, :south, :east, :west].include? facing
      rotate_sprites(@facing)
    else
      case facing
      when :southwest
        rotate_sprites :south
      when :southeast
        rotate_sprites :east
      when :northwest
        rotate_sprites :west
      when :northeast
        rotate_sprites :north
      end
    end
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
