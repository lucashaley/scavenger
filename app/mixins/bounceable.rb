module HuskEngine
  module Bounceable
    include Soundable

    # attr_accessor :bounce
    attr_accessor :sound_bounce

    def initialize_bounceable(
      # bounce: 0.7,
      sound_bounce: 'sounds/clank.wav'
    )

      # @bounce = bounce
      @sound_bounce = sound_bounce

      raise StandardError "#{class_name}: method ~bounce~ is not defined" \
        unless self.class.instance_methods.include?(:bounce)
    end
    def bounce_x_off(bouncer, collided_on)
      play_once @sound_bounce

      # puts "bounce_x_off #{bouncer.name}, x: #{bouncer.x}"
      right_edge = @x + @w
      case collided_on
      when :east
        bouncer.x = right_edge + (right_edge - bouncer.x)
        bouncer.momentum.x *= bounce
      when :west
        bouncer.x -= (bouncer.x + bouncer.w - @x)
        bouncer.momentum.x *= -bounce
      end
    end

    def bounce_y_off(bouncer, collided_on)
      play_once @sound_bounce

      # puts 'bounce_y_off'
      case collided_on
      when :north
        bouncer.y -= (bouncer.y - bouncer.h - @y)
        bouncer.momentum.y *= -bounce
      when :south
        bouncer.y -= (bouncer.y + bouncer.h - @y)
        bouncer.momentum.y *= -bounce
      end
    end

    def bounce_off(bouncer, collided_on)
      puts "bounce_off #{bouncer.name}"
      play_once @sound_bounce unless @sound_bounce.nil?

      puts "bounce_off #{bouncer.name}: x: #{@x}, #{right_side}, #{collided_on}"


      # x: 300
      # w: 128
      # left_side: 300
      # -
      # player x: 270
      # player right_side: 302

      case collided_on
      when :east
        bouncer.x = right_side + (right_side - bouncer.x)
        bouncer.momentum.x *= -bounce
      when :west
        bouncer.x = left_side - bouncer.w - (bouncer.right_side - left_side)
        # bouncer.x -= (bouncer.x + bouncer.w - @x)
        bouncer.momentum.x *= -bounce
      when :north
        bouncer.y = top_side + (top_side - bouncer.y)
        bouncer.momentum.y *= -bounce
      when :south
        bouncer.y = bottom_side - bouncer.h - (bouncer.top_side - bottom_side)
        # bouncer.y -= (bouncer.y + bouncer.h - @y)
        bouncer.momentum.y *= -bounce
      end
    end
  end
end