module HuskGame
  class Repairer < Connector
    SPRITE_DETAILS = {
      name: "repairer",
      layers: [
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: -1
        },
        {
          name: "main",
          blendmode_enum: :alpha,
          z: 1
        },
        # {
        #   name: "lights",
        #   blendmode_enum: :add,
        #   z: 2
        # }
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

    def initialize(
      x: 0,
      y: 0,
      scale: :large,
      facing: :south,
      tolerance: 8,
      data: 0.5,
      data_rate: 0.05
    )
      super(x: x, y: y, scale: scale, facing: facing, tolerance: tolerance, data: data, data_rate: data_rate)
    end

    def collide_action(collidee, collided_on)
      # puts "REPAIRER COLLIDE"
      puts "Connector: collidee facing: #{collidee.facing}, collided_on: #{collided_on}, facing: #{@facing}, remaining: #{@remaining_data}"
      # puts "previous_tick: #{@previous_data_tick}"

      # Get the turret direction from the player
      # and compare it to the collision facing
      if @remaining_data > 0

        # puts "WERE IN"

        # This stops the overlap and bounce, and the weird y collision stuff
        # This would all be easier if we did predictive collision, instead of reactive
        case collided_on
        when :north
          collidee.y = @y + @h
          collidee.momentum.y = 0.0
        when :south
          collidee.y = @y - collidee.h
          collidee.momentum.y = 0.0
        when :east
          collidee.x = @x + @w
          collidee.momentum.x = 0.0
        when :west
          collidee.x = @x - collidee.w
          collidee.momentum.x = 0.0
        end

        # This is ripped from the door
        # Possible chance of optimization/refactor
        # puts "tolerance: #{@tolerance}"
        entering = case collided_on
                   when :north, :south
                     collidee.center_x.between?(center_x - @tolerance, center_x + @tolerance)
                   when :east, :west
                     collidee.center_y.between?(center_y - @tolerance, center_y + @tolerance)
                   end
        # puts "entering: #{entering}"
        if entering
          @interfacing = true

          # opposite_facing = case collided_on
          #                   when :north
          #                     :south
          #                   when :south
          #                     :north
          #                   when :east
          #                     :west
          #                   when :west
          #                     :east
          #                   end
          # collidee.change_health @data_rate, opposite_facing
          collidee.change_health @data_rate, collided_on

          # reduce_data @data_rate
          # TODO Add this back in again once we have light sprites for repairer

          if @remaining_data <= 0

            # audio_feedback = @corrupted ? "sounds/data_corrupted.wav" : "sounds/data_collected.wav"
            # play_once audio_feedback
          end

          @previous_data_tick = Kernel.tick_count
        else
          puts "missed!"
          bounce_off(collidee, collided_on)
        end
      else
        # play_once @sound_collide
        bounce_off(collidee, collided_on)
      end
    end

    def bounce
      0.0
    end
  end
end