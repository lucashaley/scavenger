module HuskGame
  class Repairer < Connector

    sprite_data 'repairer'

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

      @audio_idle = HuskGame::AssetPaths::Audio::REPAIRER_IDLE
    end

    def collide_action(collidee, collided_on)
      # puts "REPAIRER COLLIDE"
      # puts "previous_tick: #{@previous_data_tick}"

      # Get the turret direction from the player
      # and compare it to the collision facing
      # if @remaining_data > 0 # we're not using data

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

        if aligned_with?(collidee, collided_on, @tolerance)
          @interfacing = true
          collidee.change_health @data_rate, collided_on
        else
          bounce_off(collidee, collided_on)
        end
      # else
      #   # play_once @sound_collide
      #   bounce_off(collidee, collided_on)
      # end
    end

    def bounce
      0.0
    end
  end
end