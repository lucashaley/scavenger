module HuskEngine
  module Boundable
    # Constrain entity within bounds and reverse momentum on collision.
    # Expects a bounds hash with :top, :right, :bottom, :left keys.
    def bounds_inside_x(bounds)
      if @x + @w > bounds.right
        @x -= (@x + @w - bounds.right)
        @momentum.x *= -1.0
      elsif @x < bounds.left
        @x += bounds.left - @x
        @momentum.x *= -1.0
      end
    end

    def bounds_inside_y(bounds)
      if @y + @h > bounds.top
        @y -= (@y + @h - bounds.top)
        @momentum.y *= -1.0
      elsif @y < bounds.bottom
        @y += bounds.bottom - @y
        @momentum.y *= -1.0
      end
    end

    def bounds_inside(bounds)
      bounds_inside_x(bounds)
      bounds_inside_y(bounds)
    end
  end
end
