class Ship < Zif::CompoundSprite
  include Faceable
  include Scaleable
  include Collideable

  attr_accessor :health_thrust, :health_ccw, :health_cw
  attr_accessor :health_east, :health_west, :health_north, :health_south
  attr_accessor :momentum, :energy, :effect
  attr_accessor :thrust, :angular_thrust
  attr_accessor :drag, :angular_drag
  attr_accessor :is_player, :player_control
  attr_accessor :is_rotating, :is_effectable
  attr_accessor :thrust_sprite
  # attr_accessor :scale

  TILE_SIZE = {
    small: 16,
    medium: 32,
    large: 64
  }
  SCALED_THRUST = {
    small: 0.25,
    medium: 0.5,
    large: 1.0
  }
  # SPRITE_SCALES = {
  #   small: 16,
  #   medium: 32,
  #   large: 64
  # }
  # def sprite_scales scale
  #   SPRITE_SCALES[scale]
  # end
  COLLISION_SCALES = {
    large: 64,
    medium: 32,
    small: 16
  }
  def collision_scales scale
    COLLISION_SCALES[scale]
  end

  def initialize (
    name: Zif.unique_name('ship'),
    x: 0,
    y: 0,
    scale_factor: 1, # This isn't used
    thrust: 3,
    angular_thrust: 6, # This is irritatingly in ticks
    drag: 0.9,
    angular_drag: 0.9
  )
    super(name)

    @h = 64
    @w = 64

    # @ship_sprite_32 = Zif::Sprite.new.tap do |s|
    #   s.x = 0
    #   s.y = 10
    #   s.w = 32
    #   s.h = 32
    #   s.path = "sprites/1bit_ship_32.png"
    # end
    @ship_sprite_32 = $services[:sprite_registry].construct(:ship_32).tap do |s|
      s.y = 0
    end
    @ship_sprite_16 = $services[:sprite_registry].construct(:ship_16).tap do |s|
      s.y = 0
    end
    # @thrust_sprite_north_32 = Zif::Sprite.new.tap do |s|
    #   s.x = 0
    #   s.y = 0
    #   s.w = 32
    #   s.h = 8
    #   s.path = "sprites/ship_thrust_00.png"
    #   s.blendmode_enum = :add
    # end
    # @thrust_sprite_south_32 = Zif::Sprite.new.tap do |s|
    #   s.x = 0
    #   s.y = 32
    #   s.w = 32
    #   s.h = 8
    #   s.angle = 180
    #   s.path = "sprites/ship_thrust_00.png"
    #   s.blendmode_enum = :add
    # end
    # @thrust_sprite_east_32 = Zif::Sprite.new.tap do |s|
    #   s.x = -16
    #   s.y = 16
    #   s.w = 32
    #   s.h = 8
    #   s.angle = 90
    #   s.path = "sprites/ship_thrust_00.png"
    #   s.blendmode_enum = :add
    # end
    # @thrust_sprite_west_32 = Zif::Sprite.new.tap do |s|
    #   s.x = 16
    #   s.y = 16
    #   s.w = 32
    #   s.h = 8
    #   s.angle = 270
    #   s.path = "sprites/ship_thrust_00.png"
    #   s.blendmode_enum = :add
    # end
    # @turret_sprite_32 = Zif::Sprite.new.tap do |s|
    #   s.x = 0
    #   s.y = 5
    #   s.w = 32
    #   s.h = 32
    #   s.path = "sprites/ship_turret.png"
    # end
    # $game.services.named(:action_service).register_actionable(@turret_sprite_32)

    @ship_sprite_64 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = 0
      s.w = 64
      s.h = 64
      s.path = "sprites/1bit_ship_64.png"
    end

    @thrust_sprite_north_64 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = -10
      s.w = 64
      s.h = 16
      s.path = "sprites/ship_thrust_00.png"
      s.blendmode_enum = :add
    end
    @thrust_sprite_south_64 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = 64 - 10
      s.w = 64
      s.h = 16
      s.angle = 180
      s.path = "sprites/ship_thrust_00.png"
      s.blendmode_enum = :add
    end
    @thrust_sprite_east_64 = Zif::Sprite.new.tap do |s|
      s.x = -32
      s.y = 32 - 10
      s.w = 64
      s.h = 16
      s.angle = 90
      s.path = "sprites/ship_thrust_00.png"
      s.blendmode_enum = :add
    end
    @thrust_sprite_west_64 = Zif::Sprite.new.tap do |s|
      s.x = 32
      s.y = 32 - 10
      s.w = 64
      s.h = 16
      s.angle = 270
      s.path = "sprites/ship_thrust_00.png"
      s.blendmode_enum = :add
    end

    @turret_sprite_64 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = 0
      s.w = 64
      s.h = 64
      s.path = "sprites/ship_turret.png"
    end
    $game.services.named(:action_service).register_actionable(@turret_sprite_64)
    @turret_sprite_32 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = 0
      s.w = 32
      s.h = 32
      s.path = "sprites/ship_turret_32.png"
    end
    $game.services.named(:action_service).register_actionable(@turret_sprite_32)
    @turret_sprite_16 = Zif::Sprite.new.tap do |s|
      s.x = 0
      s.y = 0
      s.w = 16
      s.h = 16
      s.path = "sprites/ship_turret_16.png"
    end
    $game.services.named(:action_service).register_actionable(@turret_sprite_16)

    @current_sprite_hash = {
      ship: nil,
      thrust_north: nil,
      thrust_south: nil,
      thrust_east: nil,
      thrust_west: nil,
      turret: nil
    }
    @sprite_scale_hash = {
      large:
      {
        ship: @ship_sprite_64,
        thrust_north: @thrust_sprite_north_64,
        thrust_south: @thrust_sprite_south_64,
        thrust_east: @thrust_sprite_east_64,
        thrust_west: @thrust_sprite_west_64,
        turret: @turret_sprite_64
      },
      medium:
      {
        ship: @ship_sprite_32,
        thrust_north: @thrust_sprite_north_32,
        thrust_south: @thrust_sprite_south_32,
        thrust_east: @thrust_sprite_east_32,
        thrust_west: @thrust_sprite_west_32,
        turret: @turret_sprite_32
      },
      small:
      {
        ship: @ship_sprite_16,
        thrust_north: @thrust_sprite_north_32,
        thrust_south: @thrust_sprite_south_32,
        thrust_east: @thrust_sprite_east_32,
        thrust_west: @thrust_sprite_west_32,
        turret: @turret_sprite_16
      }
    }

    @momentum = {
      x: 0,
      y: 0,
      rotation: 0
    }
    @energy = {
      x: 0,
      y: 0
    }
    @effect = {
      x: 0,
      y: 0
    }

    @thrust_default = thrust
    @thrust = thrust
    @angular_thrust = angular_thrust
    @drag = drag
    @angular_drag = angular_drag
    @health_thrust = @health_ccw = @health_cw = 1.0
    @health_north = @health_south = @health_east = @health_west = 1.0

    @facing = :north

    @is_player = true
    @player_control = true
    @is_rotating = false
    @is_effectable = true

    # initialize_collision
    set_scale :large
  end

  # def set_scale(scale=:large)
  #   puts "set_scale: #{scale}"
  #   @scale = scale
  #   @current_sprite_hash = @sprites_hash[@scale]
  #   # @sprites = @current_sprite_hash.values
  #   refresh_sprites
  # end
  #
  # def refresh_sprites
  #   @sprites = @current_sprite_hash.values
  # end

  def add_thrust_x input
    health_multiplier = input < 0 ? @health_west : @health_east
    @energy.x += input * @thrust * health_multiplier * SCALED_THRUST[@scale]
  end
  def add_thrust_y input
    health_multiplier = input < 0 ? @health_south : @health_north
    @energy.y += input * @thrust * health_multiplier * SCALED_THRUST[@scale]
  end
  def add_thrust x=0, y=0
    health_multiplier_x = x < 0 ? @health_west : @health_east
    health_multiplier_y = y < 0 ? @health_south : @health_north
    @energy.x += x * @thrust * health_multiplier_x * SCALED_THRUST[@scale]
    @energy.y += y * @thrust * health_multiplier_y * SCALED_THRUST[@scale]
  end

  def calc_rotation
    @angle += @momentum.rotation
  end
  def calc_position_x
    @momentum.x += @energy.x
    @momentum.x += @effect.x if @is_effectable
    @x += @momentum.x
    @x.truncate

    # Render the jets here, not a great place
    if @energy.x >= 0
      # This is a problem now that we're switching scales
      # @thrust_sprite_east.path = "sprites/ship_thrust_0#{@energy.x.clamp(0, 3).truncate}.png"
      @current_sprite_hash[:thrust_east].path = \
        "sprites/ship_thrust_0#{@energy.x.clamp(0, 3).truncate}.png" \
        unless @current_sprite_hash[:thrust_east].nil?
    end
    if @energy.x <= 0
      # @thrust_sprite_west.path = "sprites/ship_thrust_0#{@energy.x.abs.clamp(0, 3).truncate}.png"
      @current_sprite_hash[:thrust_west].path = \
        "sprites/ship_thrust_0#{@energy.x.abs.clamp(0, 3).truncate}.png" \
        unless @current_sprite_hash[:thrust_west].nil?
    end
    refresh_sprites

    # Reset the movement
    @effect.x = 0
    @energy.x = 0
  end
  def calc_positon_y
    @momentum.y += @energy.y
    @momentum.y += @effect.y if @is_effectable
    @y += @momentum.y
    @y.truncate

    # Render the jets here, not a great place
    if @energy.y >= 0
      # @thrust_sprite_north.path = "sprites/ship_thrust_0#{@energy.y.clamp(0, 3).truncate}.png"
      @current_sprite_hash[:thrust_north].path = \
        "sprites/ship_thrust_0#{@energy.y.clamp(0, 3).truncate}.png" \
        unless @current_sprite_hash[:thrust_north].nil?
    end
    if @energy.y <= 0
      # @thrust_sprite_south.path = "sprites/ship_thrust_0#{@energy.y.abs.clamp(0, 3).truncate}.png"
      @current_sprite_hash[:thrust_south].path = \
        "sprites/ship_thrust_0#{@energy.y.abs.clamp(0, 3).truncate}.png" \
        unless @current_sprite_hash[:thrust_south].nil?
    end
    refresh_sprites

    # Reset the movement
    @effect.y = 0
    @energy.y = 0
  end

  def rotate_ccw
    puts 'Ship rotate_ccw'
    return if @is_rotating

    @is_rotating = true
    duration = (@angular_thrust / @health_ccw).truncate

    run_action(
      Zif::Actions::Sequence.new(
        [
          @current_sprite_hash[:turret].new_action(
            {angle: @current_sprite_hash[:turret].angle+45},
            duration: duration,
            easing: :smooth_start
          ),
          @current_sprite_hash[:turret].new_action(
            {angle: @current_sprite_hash[:turret].angle+90},
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
    puts 'Ship rotate_cw'
    duration = (@angular_thrust / @health_cw).truncate
    run_action(
      Zif::Actions::Sequence.new(
        [
          @current_sprite_hash[:turret].new_action(
            {angle: @current_sprite_hash[:turret].angle-45},
            duration: duration,
            easing: :smooth_start
          ),
          @current_sprite_hash[:turret].new_action(
            {angle: @current_sprite_hash[:turret].angle-90},
            duration: duration,
            easing: :smooth_stop
          ) { end_rotate_cw }
        ]
      )
    )
  end

  def end_rotate_cw
    puts 'end_rotate_cw'
    face_turn_cw
    @is_rotating = false
  end

  def apply_drag
    # puts 'apply_drag'
    @momentum.x = (@momentum.x * @drag).truncate
    @momentum.y = (@momentum.y * @drag).truncate
    @momentum.rotation = @momentum.rotation * @angular_drag

    # if @thrust > 0
    #   if @momentum.y >= 0
    #     @thrust_sprite_north.path = "sprites/ship_thrust_0#{@momentum.y.clamp(0, 3)}.png"
    #   elsif @momentum.y <= 0
    #     @thrust_sprite_south.path = "sprites/ship_thrust_0#{@momentum.y.abs.clamp(0, 3)}.png"
    #   end
    #
    #   if @momentum.x >= 0
    #     @thrust_sprite_east.path = "sprites/ship_thrust_0#{@momentum.x.clamp(0, 3)}.png"
    #   elsif @momentum.x <= 0
    #     @thrust_sprite_west.path = "sprites/ship_thrust_0#{@momentum.x.abs.clamp(0, 3)}.png"
    #   end
    # else
    #   puts "Thrust: #{@thrust}"
    # end

    # if @energy.y >= 0
    #   @thrust_sprite_north.path = "sprites/ship_thrust_0#{@energy.y.clamp(0, 3).truncate}.png"
    # end
    # if @energy.y <= 0
    #   @thrust_sprite_south.path = "sprites/ship_thrust_0#{@energy.y.abs.clamp(0, 3).truncate}.png"
    # end
    # if @energy.x >= 0
    #   @thrust_sprite_east.path = "sprites/ship_thrust_0#{@energy.x.clamp(0, 3).truncate}.png"
    # end
    # if @energy.x <= 0
    #   @thrust_sprite_west.path = "sprites/ship_thrust_0#{@energy.x.abs.clamp(0, 3).truncate}.png"
    # end
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
