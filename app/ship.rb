class Ship < Zif::CompoundSprite
  include Faceable
  include Scaleable
  include Collideable
  include Zif::Traceable

  attr_accessor :health_thrust, :health_ccw, :health_cw
  attr_accessor :health_east, :health_west, :health_north, :health_south
  attr_accessor :momentum, :energy, :effect
  attr_accessor :thrust, :angular_thrust
  attr_accessor :drag, :angular_drag
  attr_accessor :is_player, :player_control
  attr_accessor :is_rotating, :is_effectable, :is_interfacing, :is_dooring
  attr_accessor :thrust_sprite
  attr_accessor :data, :data_progress
  attr_reader :data_blocks, :data_block_count

  SPRITE_DETAILS = {
    name: "ship",
    layers: [
      {
        name: "main",
        blendmode_enum: :alpha,
        z: 0
      },
      {
        name: "turret",
        blendmode_enum: :alpha,
        z: 1
      },
      {
        name: "thrustnorth",
        blendmode_enum: :add,
        z: 2
      },
      {
        name: "thrustsouth",
        blendmode_enum: :add,
        z: 3
      },
      {
        name: "thrusteast",
        blendmode_enum: :add,
        z: 4
      },
      {
        name: "thrustwest",
        blendmode_enum: :add,
        z: 5
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  SCALED_THRUST = {
    small: 0.25,
    medium: 0.5,
    large: 1.0
  }

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
    @tracer_service_name = :tracer
    mark_and_print("initialize")
    super(name)

    register_sprites_new
    initialize_scaleable(:large) # hardcoding this for now
    center_sprites

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
    @data = 0
    @data_blocks = []
    @data_block_count = 6

    @is_player = true
    @player_control = true
    @is_rotating = false
    @is_effectable = true
    @is_interfacing = false
    @is_dooring = false

    # initialize_collision
    # set_scale :large

    # UI Progress bar
    @data_progress = ExampleApp::ProgressBar.new(:data_progress, 440, 0, :white)
    @data_progress.x = 720 - 40 - 440 # 360 - (400 * 0.5)
    @data_progress.y = 1200
    @data_progress.view_actual_size!
  end

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
    # mark_and_print("calc_position_x")
    @momentum.x += @energy.x
    @momentum.x += @effect.x if @is_effectable
    @x += @momentum.x
    @x.truncate

    # Render the jets here, not a great place
    if @energy.x < 0
      # This is a problem now that we're switching scales
      # @thrust_sprite_east.path = "sprites/ship_thrust_0#{@energy.x.clamp(0, 3).truncate}.png"
      # @current_sprite_hash[:thrust_east].path = \
      #   "sprites/ship_thrust_0#{@energy.x.clamp(0, 3).truncate}.png" \
      #   unless @current_sprite_hash[:thrust_east].nil?
      #
      # puts "sprites/ship_thrusteast_#{@scale}_power_0#{@energy.x.clamp(0, 3).truncate}.png" if @energy.x > 0
      @current_sprite_hash[:thrusteast].path = \
        "sprites/ship/ship_thrusteast_#{@scale}_power_0#{@energy.x.clamp(0, 3).truncate}.png"
    # end
    # if @energy.x <= 0
    elsif @energy.x > 0
      # @thrust_sprite_west.path = "sprites/ship_thrust_0#{@energy.x.abs.clamp(0, 3).truncate}.png"
      # @current_sprite_hash[:thrust_west].path = \
      #   "sprites/ship_thrust_0#{@energy.x.abs.clamp(0, 3).truncate}.png" \
      #   unless @current_sprite_hash[:thrust_west].nil?
      #
      @current_sprite_hash[:thrustwest].path = \
        "sprites/ship/ship_thrustwest_#{@scale}_power_0#{@energy.x.clamp(0, 3).truncate}.png"
    else
      @current_sprite_hash[:thrusteast].path = "sprites/ship/ship_thrusteast_#{@scale}.png"
      @current_sprite_hash[:thrustwest].path = "sprites/ship/ship_thrustwest_#{@scale}.png"
    end

    refresh_sprites

    # Reset the movement
    @effect.x = 0
    @energy.x = 0
  end

  def predict_position_y
    new_momentum_y = @momentum.y + @energy.y
    new_momentum_y += @effect.y if @is_effectable
    new_y = @y + new_momentum_y
    new_y.truncate
  end

  def calc_position_y
    # mark_and_print("calc_position_y")
    @momentum.y += @energy.y
    @momentum.y += @effect.y if @is_effectable
    @y += @momentum.y
    @y.truncate

    # Render the jets here, not a great place
    if @energy.y < 0
      # @thrust_sprite_north.path = "sprites/ship_thrust_0#{@energy.y.clamp(0, 3).truncate}.png"
      # @current_sprite_hash[:thrust_north].path = \
      #   "sprites/ship/ship_thrust_0#{@energy.y.clamp(0, 3).truncate}.png" \
      #   unless @current_sprite_hash[:thrust_north].nil?
      @current_sprite_hash[:thrustnorth].path = \
        "sprites/ship/ship_thrustnorth_#{@scale}_power_0#{@energy.x.clamp(0, 3).truncate}.png"
    elsif @energy.y > 0
      # @thrust_sprite_south.path = "sprites/ship_thrust_0#{@energy.y.abs.clamp(0, 3).truncate}.png"
      # @current_sprite_hash[:thrust_south].path = \
      #   "sprites/ship/ship_thrust_0#{@energy.y.abs.clamp(0, 3).truncate}.png" \
      #   unless @current_sprite_hash[:thrust_south].nil?
      @current_sprite_hash[:thrustsouth].path = \
        "sprites/ship/ship_thrustsouth_#{@scale}_power_0#{@energy.x.clamp(0, 3).truncate}.png"
    else
      @current_sprite_hash[:thrustnorth].path = "sprites/ship/ship_thrustnorth_#{@scale}.png"
      @current_sprite_hash[:thrustsouth].path = "sprites/ship/ship_thrustsouth_#{@scale}.png"
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

  def add_data (amount)
    # puts "Ship:add_data #{amount}"
    @data += amount
    @data_progress.progress = @data * 0.001
  end

  def add_data_block(name:, size:, corrupted:)
    puts "add_data_block: #{@data_blocks.length} vs #{@data_block_count}"
    if @data_blocks.length < @data_block_count
      @data_blocks << {name: name, size: size, corrupted: corrupted}
    end
    puts "data_blocks: #{@data_blocks}"
    @data_progress.progress = 0
  end

  def render_data_blocks
    output = []
    x_offset = 600
    y_offset = 40
    @data_block_count.times do |i|
      data = @data_blocks[i]
      data_corrupted = nil
      unless data.nil?
        data_corrupted = data[:corrupted]
      end
      case data_corrupted
      when true
        c = 155
      when false
        c = 224
      when nil
        c = 32
      end
      output << {
        x: x_offset,
        y: (20 * i) + y_offset,
        w: 64,
        h: 16,
        r: c - 16,
        g: c,
        b: c - 16,
        primitive_marker: :solid
      }
      output << {
        x: x_offset,
        y: (20 * i) + y_offset,
        w: 64,
        h: 16,
        r: 255,
        g: 255,
        b: 255,
        primitive_marker: :border
      }
    end
    return output
  end

  # def self.register_sprites
  #   puts "Ship: Registering Sprites"
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_main_large",
  #     width: 64,
  #     height: 64
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_main_large",
  #     :ship_main_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_main_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_main_medium",
  #     :ship_main_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_main_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_main_small",
  #     :ship_main_small
  #   )
  #
  #   # TURRET
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_turret_large",
  #     width: 64,
  #     height: 64
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_turret_large",
  #     :ship_turret_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_turret_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_turret_medium",
  #     :ship_turret_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_turret_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_turret_small",
  #     :ship_turret_small
  #   )
  #
  #   # THRUSTNORTH
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustnorth_large",
  #     width: 96,
  #     height: 96
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustnorth_large",
  #     :ship_thrustnorth_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustnorth_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustnorth_medium",
  #     :ship_thrustnorth_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustnorth_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustnorth_small",
  #     :ship_thrustnorth_small
  #   )
  #
  #   # THRUSTSOUTH
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustsouth_large",
  #     width: 96,
  #     height: 96
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustsouth_large",
  #     :ship_thrustsouth_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustsouth_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustsouth_medium",
  #     :ship_thrustsouth_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustsouth_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustsouth_small",
  #     :ship_thrustsouth_small
  #   )
  #
  #   # THRUSTEAST
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrusteast_large",
  #     width: 96,
  #     height: 96
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrusteast_large",
  #     :ship_thrusteast_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrusteast_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrusteast_medium",
  #     :ship_thrusteast_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrusteast_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrusteast_small",
  #     :ship_thrusteast_small
  #   )
  #
  #   # THRUSTWEST
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustwest_large",
  #     width: 96,
  #     height: 96
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustwest_large",
  #     :ship_thrustwest_large
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustwest_medium",
  #     width: 32,
  #     height: 32
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustwest_medium",
  #     :ship_thrustwest_medium
  #   )
  #
  #   $services[:sprite_registry].register_basic_sprite(
  #     "ship/ship_thrustwest_small",
  #     width: 16,
  #     height: 16
  #   )
  #   $services[:sprite_registry].alias_sprite(
  #     "ship/ship_thrustwest_small",
  #     :ship_thrustwest_small
  #   )
  # end
end
