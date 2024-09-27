class Player < Zif::Sprite
  include Faceable

  attr_accessor :health_thrust, :health_ccw, :health_cw
  attr_accessor :momentum
  attr_accessor :thrust, :angular_thrust
  attr_accessor :drag, :angular_drag
  attr_accessor :is_player
  attr_accessor :is_rotating

  def initialize (
    prototype,
    x=0,
    y=0,
    scale_factor=1,
    thrust=4.0,
    angular_thrust=6, # This is irritatingly in ticks
    drag=0.9,
    angular_drag=0.9
  )
    super()
    assign(prototype.to_h)

    @momentum = {
      x: 0,
      y: 0,
      rotation: 0
    }

    @thrust_default = thrust
    @thrust = thrust
    @angular_thrust = angular_thrust
    @drag = drag
    @angular_drag = angular_drag
    @health_thrust = @health_ccw = @health_cw = 1.0

    @facing = 0

    @is_player = true
    @is_rotating = false
  end

  def add_rotation input
    @momentum.rotation += input * @angular_thrust
    case input
    when 0..Float::INFINITY
      @momentum.rotation * @health_ccw
    when -Float::INFINITY..0
      @momentum.rotation * @health_cw
    end
  end
  def add_thrust_x input
    @momentum.x += input * @thrust * @health_thrust
  end
  def add_thrust_y input
    @momentum.y += input * @thrust * @health_thrust
  end
  def add_thrust x=0, y=0
    @momentum.x += x * @thrust * @health_thrust
    @momentum.y += y * @thrust * @health_thrust
  end

  def calc_rotation
    @angle += @momentum.rotation
  end
  def calc_position_x
    @x += @momentum.x
  end
  def calc_positon_y
    @y += @momentum.y
  end

  def rotate_ccw
    puts 'Player rotate_ccw'
    return if @is_rotating

    @is_rotating = true
    duration = (@angular_thrust / @health_ccw).truncate
    self.run_action(
      Zif::Actions::Sequence.new(
        [

          new_action(
            {angle: @angle+45},
            duration: duration,
            easing: :smooth_start
          ),
          new_action(
            {angle: @angle+90},
            duration: duration,
            easing: :smooth_stop
          ) { end_rotate_ccw }
        ]
      )
    )
  end

  def end_rotate_ccw
    puts 'end_rotate_ccw'
    face_turn_ccw
    @is_rotating = false
  end

  def rotate_cw
    puts 'Player rotate_cw'
    duration = (@angular_thrust / @health_cw).truncate
    self.run_action(
      Zif::Actions::Sequence.new(
        [

          new_action(
            {angle: @angle-45},
            duration: duration,
            easing: :smooth_start
          ),
          new_action(
            {angle: @angle-90},
            duration: duration,
            easing: :smooth_stop
          ) { face_turn_cw }
        ]
      )
    )
  end

  def apply_drag
    @momentum.x = (@momentum.x * @drag).truncate
    @momentum.y = (@momentum.y * @drag).truncate
    @momentum.rotation = @momentum.rotation * @angular_drag

    # puts @momentum
  end

  def handle_collision
    puts 'handle_collision'
  end

  # This is expecting a rect hash, with top, bottom, left, right
  # _Not_ a rect with x, y, w, h
  def bounds_inside_x bounds
    if @x + @w > bounds.right
      @x -= (@x + @w - bounds.right)
      @momentum.x *= -1.0
    elsif @x < bounds.left
      @x += bounds.left - @x
      @momentum.x *= -1.0
    end
  end

  def bounds_inside_y bounds
    if @y + @h > bounds.top
      @y -= (@y + @h - bounds.top)
      @momentum.y *= -1.0
    elsif @y < bounds.bottom
      @y += bounds.bottom - @y
      @momentum.y *= -1.0
    end
  end

  def bounds_inside bounds
    if @x + @w > bounds.right
      @x -= (@x + @w - bounds.right)
      @momentum.x *= -1.0
    elsif @x < bounds.left
      @x += bounds.left - @x
      @momentum.x *= -1.0
    end
    if @y + @h > bounds.top
      @y -= (@y + @h - bounds.top)
      @momentum.y *= -1.0
    elsif @y < bounds.bottom
      @y += bounds.bottom - @y
      @momentum.y *= -1.0
    end
  end

  def bounce_x_off off
    if @x > off.x
      right_edge = off.x + off.w
      @x = right_edge + (right_edge - @x)
      @momentum.x *= -off.bounce
    elsif x < off.x
      @x -= (@x + @w - off.x)
      @momentum.x *= -off.bounce
    end
  end

  def bounce_y_off off
    puts 'bounce_y_off'
    puts off
    if @y > off.y
      @y -= (@y - @h - off.y)
      @momentum.y *= -off.bounce
    elsif @y < off.y
      @y -= (@y + @h - off.y)
      @momentum.y *= -off.bounce
    end
    # if $gtk.args.state.player.y > collision_y.y
    #     $gtk.args.state.player.y -= ($gtk.args.state.player.y - $gtk.args.state.player.h - collision_y.y)
    #     $gtk.args.state.player.thrust.y *= -@wall_bounce
    #   elsif $gtk.args.state.player.y < collision_y.y
    #     $gtk.args.state.player.y -= ($gtk.args.state.player.y + $gtk.args.state.player.h - collision_y.y)
    #     $gtk.args.state.player.thrust.y *= -@wall_bounce
    #   end
  end

  def boost_thrust amount=10, duration=3.seconds, start_duration=10
    puts 'boost_thrust'
    current_thrust = @thrust

    run_action(
      Zif::Actions::Sequence.new(
        [
          new_action({thrust: current_thrust + amount}, duration: start_duration, easing: :smooth_start) do
            puts 'finish boost'
          end,

          new_action({thrust: current_thrust}, duration: duration, easing: :smooth_stop) do
            puts 'returned thrust'
          end
        ]
      )
    )
  end
end
