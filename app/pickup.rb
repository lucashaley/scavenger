
module HuskGame
  class Pickup < Zif::CompoundSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Bounceable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Tickable
    include HuskEngine::Shadowable

    def initialize(
      x: 0,
      y: 0,
      # bounce: 0.8,
      scale: :large
    )
      super(Zif.unique_name(class_name))

      set_position(x, y)

      # collate_sprites 'boost'
      # set_scale scale
      initialize_shadowable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      rotate_sprites([:north, :south, :east, :west].sample)
      initialize_collideable(sound_collide: 'sounds/pickup.wav')
      initialize_bounceable(sound_bounce: 'sounds/thump.wav')
      initialize_bufferable(:single)
      initialize_tickable

      @sound_pickup_success = "sounds/pickup.wav"
    end

    def collide_action collidee, facing
      # puts "collide_action: #{facing}"

      # Get the turret direction from the player
      # and compare it to the collision facing
      if (collidee.facing == :north && facing == :south) ||
        (collidee.facing == :south && facing == :north) ||
        (collidee.facing == :west && facing == :east) ||
        (collidee.facing == :east && facing == :west)
        play_once @sound_pickup_success

        # Do the thing!
        perform_pickup collidee

        kill
      else
        play_once @sound_bounce
        bounce_off(collidee, facing)
      end
    end

    def bounce
      puts "pickup bounce"
      # puts "bounce: #{BOUNCE_SCALES[@scale]}"
      self.class::BOUNCE_SCALES[@scale]
    end

    def perform_tick
      # puts "BoostThrust: perform_tick"
      perform_shadow_tick
    end

    def perform_pickup collidee
      puts "You should override this"
    end
  end
end