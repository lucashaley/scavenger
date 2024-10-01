module HuskGame
  class Breach < Zif::CompoundSprite
    include HuskEngine::Collideable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable

    attr_accessor :locked

    SPRITE_DETAILS = {
      name: "breach",
      layers: [
        {
          name: "base",
          blendmode_enum: :alpha,
          z: 0
        },
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
    }.freeze

    def initialize
      super(Zif.unique_name('Breach'))

      x = 40 + (640 - 64).half
      y = 1280 - 48 - 64 - 640.half
      set_position(x, y)

      # Temporary force
      register_sprites_new
      initialize_scaleable(:large)

      initialize_bufferable(:double)
      initialize_collideable

      center_sprites

      @previous_location = nil
      @move_threshold = 4
      @distance_threshold = 128
      @hold_threshold = 2.seconds
      @current_hold = 0
      @docking = false
      @locked = false
    end

    def collide_action(collidee, collided_on)
      puts "BUFFER COLLIDE"

      current_location = collidee.xy

      unless @previous_location.nil?
        move_dist = $gtk.args.geometry.distance_squared(current_location, @previous_location)
        # puts "move_dist: #{move_dist}"

        # check if the player is moving
        if move_dist <= @move_threshold
          # then check if the player is near the middle of the breach
          center_dist = $gtk.args.geometry.distance_squared(collidee.center, self.center)
          puts "center_dist: #{center_dist}"
          if center_dist <= @distance_threshold
            @docking = true
            @current_hold += 1

            # Start the docking animation


            # Lock the player in if dock time is done
            lock_in(collidee) if @current_hold >= @hold_threshold
          else
            puts "TOO FAR"
            @docking = false
            @current_hold = 0
          end
        else
          @docking = false
          @current_hold = 0
        end
      end

      # Update for next tick
      @previous_location = current_location
    end

    def lock_in player
      puts "LOCK IN!!!!!!"

      # Move the player to the center
      player.run_action(
        Zif::Actions::Action.new(
          player,
          {
            x: @x,
            y: @y
          },
          duration: 10,
          easing: :smooth_stop4
        ) { @locked = true }
      )
    end
  end
end