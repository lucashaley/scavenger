class Attractor < HuskGame::HuskSprite
  include HuskEngine::Collideable
  include HuskEngine::Deadable
  include HuskEngine::Effectable
  include HuskEngine::Scaleable
  include HuskEngine::Bufferable
  include HuskEngine::Shadowable
  include HuskEngine::Tickable
  include Zif::Traceable

  sprite_data 'attractor'

  def initialize(
    x: 0,
    y: 0,
    scale: :large,
    effect_strength: 50
  )
    super(Zif.unique_name('Attractor'))
    @tracer_service_name = :tracer

    set_position(x, y)

    initialize_deadable
    initialize_shadowable
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_bounceable
    initialize_bufferable(:single)
    initialize_tickable

    @sound_collide = HuskGame::AssetPaths::Audio::THUMP

    @effect_strength = effect_strength
    @effect_direction = 1 # attract
    @effect_active = false
  end

  def collide_action(collidee, facing)
    play_once @sound_collide
    if facing == :east || facing == :west
      bounce_x_off collidee, facing
    end
    if facing == :north || facing == :south
      bounce_y_off collidee, facing
    end
  end

  def perform_tick
    perform_shadow_tick
  end

  def bounce
    HuskGame::Constants::HAZARD_BOUNCE
  end
end
