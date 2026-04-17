class Repulsor < HuskGame::HuskSprite
  include HuskEngine::Collideable
  include HuskEngine::Deadable
  include HuskEngine::Effectable
  include HuskEngine::Scaleable
  include HuskEngine::Bufferable
  include Zif::Traceable

  sprite_data 'repulsor'

  def initialize(
    x: 0,
    y: 0,
    scale: :large,
    effect_strength: rand(20) + 10 # 50
  )
    super(Zif.unique_name('Repulsor'))
    @tracer_service_name = :tracer

    set_position(x, y)

    initialize_deadable
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_bounceable
    initialize_bufferable(:single)

    @sound_collide = HuskGame::AssetPaths::Audio::THUMP

    @effect_strength = effect_strength
    @effect_direction = -1 # repulse
    @effect_active = false
  end

  def collide_action(collidee, facing)
    if facing == :east || facing == :west
      bounce_x_off collidee, facing
    end
    if facing == :north || facing == :south
      bounce_y_off collidee, facing
    end
  end

  # This is a bit hacky to add the generic shadow
  def register_sprites_new
    super

    $game.services[:sprite_registry].alias_sprite(
      "shadow_large",
      :repulsor_shadow_large
    )
    $game.services[:sprite_registry].alias_sprite(
      "shadow_medium",
      :repulsor_shadow_medium
    )
    $game.services[:sprite_registry].alias_sprite(
      "shadow_small",
      :repulsor_shadow_small
    )
  end

  def bounce
    HuskGame::Constants::HAZARD_BOUNCE
  end
end
