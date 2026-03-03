class Wall < HuskGame::HuskSprite
  include HuskEngine::Collideable
  include HuskEngine::Bounceable
  include HuskEngine::Scaleable
  include HuskEngine::Faceable

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }

  # Load sprite details from external YAML file
  def self.sprite_details
    @sprite_details ||= $game.services[:sprite_data_loader].load('wall')
  end

  def initialize (
    x: 360,
    y: 900,
    # bounce=0.8,
    facing: :north,
    scale: :large
  )
    super(Zif.unique_name("Wall#{facing.to_s}"))

    set_position(x, y)

    # Corner pieces use a different sprite directory.
    # Note: this mutates the shared SPRITE_DETAILS constant, but each Wall
    # sets the name before its own registration/initialization so it's safe.
    unless [:north, :south, :east, :west].include? facing
      SPRITE_DETAILS[:name] = 'wallcorner'
    else
      SPRITE_DETAILS[:name] = 'wall'
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
