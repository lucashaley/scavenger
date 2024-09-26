module HuskGame
  class Dressing < Zif::CompoundSprite
    include HuskEngine::Collideable
    include HuskEngine::Bounceable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Shadowable
    include HuskEngine::Tickable
    include Zif::Traceable

    def initialize(
      x: 360,
      y: 900,
      scale: :large
    )
      @tracer_service_name = :tracer
      super(Zif.unique_name(class_name))

      @sound_collide = "sounds/thump.wav"

      set_position(x, y)

      initialize_shadowable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bounceable
      initialize_bufferable(:single)
      initialize_tickable
      rotate_sprites([:north, :south, :east, :west].sample)
    end

    def collide_action collidee, facing
      play_once @sound_collide
      bounce_off(collidee, facing)
    end

    def perform_tick
      perform_shadow_tick
    end
  end
end
