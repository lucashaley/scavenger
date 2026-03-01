class Attractor < HuskGame::HuskSprite
  include HuskEngine::Collideable
  include HuskEngine::Bounceable
  include HuskEngine::Deadable
  include HuskEngine::Effectable
  include HuskEngine::Scaleable
  include HuskEngine::Bufferable
  include Zif::Traceable

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }

  def self.sprite_details
    @sprite_details ||= $game.services[:sprite_data_loader].load('attractor')
  end

  def initialize(
    x = 0,
    y = 0,
    scale = :large,
    effect_strength = 50
  )
    super(Zif.unique_name('Attractor'))
    @tracer_service_name = :tracer

    set_position(x, y)

    # collate_sprites "attractor"
    # set_scale scale
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_bounceable
    initialize_bufferable(:single)

    # initialize_collision
    # @bounce = 0.9
    @sound_collide = "sounds/thump.wav"

    @effect_strength = effect_strength
    @effect_active = false

    center_sprites
  end

  def collide_action(collidee, facing)
    puts 'collide_action'
    play_once @sound_collide
    if facing == :east || facing == :west
      bounce_x_off collidee, facing
    end
    if facing == :north || facing == :south
      bounce_y_off collidee, facing
    end
  end

  def perform_effect
    return unless @effect_active

    # Do we want to normalize here?
    effect_vector = $gtk.args.geometry.vec2_normalize({
      x: @x - @effect_target.x,
      y: @y - @effect_target.y
    })

    distance = $gtk.args.geometry.distance self, @effect_target
    effect_vector.x *= (1/distance) * effect_strength # @effect_strength
    effect_vector.y *= (1/distance) * effect_strength # @effect_strength
    # puts effect_vector

    # Do we want to be just adding to the momentum? Seems wrong
    @effect_target.effect.x += effect_vector.x
    @effect_target.effect.y += effect_vector.y
  end

  # This is a bit hacky to add the generic shadow
  def register_sprites_new
    super

    $services[:sprite_registry].alias_sprite(
      "shadow_large",
      :attractor_shadow_large
    )
    $services[:sprite_registry].alias_sprite(
      "shadow_medium",
      :attractor_shadow_medium
    )
    $services[:sprite_registry].alias_sprite(
      "shadow_small",
      :attractor_shadow_small
    )
  end

  def bounce
    0.9
  end
end
