module HuskEngine
  # Collideable — collision detection and response.
  # Dependencies: includes Bounceable (which includes Soundable), and Soundable directly.
  # Required methods: including class must define `collide_action(collider, side)`.
  # Init order: call `initialize_collideable` after `initialize_bounceable`.
  module Collideable
    include Bounceable
    include Soundable

    # attr_accessor :collision_rect
    attr_accessor :collision_enabled
    attr_accessor :sound_collide
    # attr_accessor :pickup

    def initialize_collideable(
      sound_collide: ''
    )
      @collision_enabled = true
      @sound_collide = sound_collide

      raise StandardError "#{class_name}: method ~collide_action~ is not defined" \
        unless self.class.instance_methods.include?(:collide_action)
    end

    # Shared collision method for both axes
    private def collide_with_axis(collider, axis)
      return unless @collision_enabled

      # Determine which side was hit based on the axis
      if axis == :x
        collided_on = collider.x < @x ? :west : :east
      else # axis == :y
        collided_on = collider.y < @y ? :south : :north
      end

      collide_action collider, collided_on
    end

    public def collide_x_with(c)
      collide_with_axis(c, :x)
    end

    def collide_y_with(c)
      collide_with_axis(c, :y)
    end
  end
end