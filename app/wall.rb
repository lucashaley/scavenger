class Wall < HuskGame::HuskSprite
  include HuskEngine::Collideable
  include HuskEngine::Scaleable
  include HuskEngine::Faceable

  sprite_data 'wall'

  def self.corner_sprite_details
    @corner_sprite_details ||= $game.services[:sprite_data_loader].load('wallcorner')
  end

  def initialize (
    x: 360,
    y: 900,
    facing: :north,
    scale: :large
  )
    super(Zif.unique_name("Wall#{facing.to_s}"))

    set_position(x, y)

    @is_corner = ![:north, :south, :east, :west].include?(facing)
    register_sprites_new

    initialize_scaleable(scale)
    initialize_collideable
    initialize_bounceable

    initialize_faceable(facing)
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

  def active_sprite_details
    @is_corner ? self.class.corner_sprite_details : self.class::SPRITE_DETAILS
  end

  def collide_action collidee, facing
    # puts "Colliding with wall!"
    # play_once @sound_bounce
    bounce_off(collidee, facing)
  end

  def bounce
    HuskGame::Constants::BOUNCE_SCALES[@scale]
  end
end
