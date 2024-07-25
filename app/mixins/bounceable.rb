module Bounceable
  include Soundable

  attr_accessor :bounce

  def bounce_x_off(bouncer, collided_on)
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
    right_edge = @x + @w
    case collided_on
    when :east
      bouncer.x = right_edge + (right_edge - bouncer.x)
      bouncer.momentum.x *= -bounce
    when :west
      bouncer.x -= (bouncer.x + bouncer.w - @x)
      bouncer.momentum.x *= -bounce
    when :north
      bouncer.y -= (bouncer.y - bouncer.h - @y)
      bouncer.momentum.y *= -bounce
    when :south
      bouncer.y -= (bouncer.y + bouncer.h - @y)
      bouncer.momentum.y *= -bounce
    end
  end

  # def bounce_off bouncer
  #   puts 'bounce_off'
  #   if b.x > @x
  #     right_edge = @x + @w
  #     b.x = right_edge + (right_edge - b.x)
  #     b.momentum.x *= -@bounce
  #   elsif b.x < @x
  #     b.x -= (b.x + b.w - @x)
  #     b.momentum.x *= -@bounce
  #   end
  #
  #   if bouncer.y > @y
  #     bouncer.y -= (bouncer.y - bouncer.h - @y)
  #     bouncer.momentum.y *= -@bounce
  #   elsif bouncer.y < @y
  #     bouncer.y -= (bouncer.y + bouncer.h - @y)
  #     bouncer.momentum.y *= -@bounce
  #   end
  # end
end
