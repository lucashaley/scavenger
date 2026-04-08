module HuskGame
  class Ship < HuskSprite
    include HuskEngine::Faceable
    include HuskEngine::Scaleable
    include HuskEngine::Collideable
    include HuskEngine::Boundable
    include HuskEngine::Shadowable
    include HuskEngine::Soundable
    include Zif::Traceable

    attr_reader :health_thrust, :health_ccw, :health_cw
    attr_reader :health_east, :health_west, :health_north, :health_south
    attr_accessor :momentum  # written externally by collision/bounce systems
    attr_reader :energy, :effect
    attr_accessor :thrust  # written by Zif Actions in boost_thrust
    attr_reader :angular_thrust, :drag, :angular_drag
    attr_reader :is_player, :is_rotating, :is_effectable, :is_interfacing
    attr_accessor :player_control, :is_dooring  # written by Door enter/exit
    attr_reader :thrust_sprite
    attr_reader :emp_count, :emp_storage
    attr_reader :data, :data_progress
    attr_reader :data_blocks, :data_block_count, :data_core

    sprite_data 'ship'

    SCALED_THRUST = {
      tiny: 0.125,
      small: 0.25,
      medium: 0.5,
      large: 1.0
    }

    MAX_SPEED = {
      tiny: 2,
      small: 4,
      medium: 6,
      large: 8
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
      super(name)

      initialize_mixins
      initialize_movement_vectors
      initialize_thrust_and_drag(thrust, angular_thrust, drag, angular_drag)
      initialize_health
      initialize_data_collection
      initialize_control_flags
      initialize_emp_system
      initialize_ui_elements
      initialize_inventory

      # puts self
    end

    private

    def initialize_mixins
      initialize_shadowable
      register_sprites_new
      initialize_scaleable(:large)
      center_sprites
    end

    THRUST_RAMP_FRAMES = 9 # frames to reach full thrust

    def initialize_movement_vectors
      @momentum = { x: 0, y: 0, rotation: 0 }
      @energy = { x: 0, y: 0 }
      @effect = { x: 0, y: 0 }
      @thrust_hold = { x: 0, y: 0 }
    end

    def initialize_thrust_and_drag(thrust, angular_thrust, drag, angular_drag)
      @thrust_default = thrust
      @thrust = thrust
      @angular_thrust = angular_thrust
      @drag = drag
      @angular_drag = angular_drag
    end

    def initialize_health
      @health_thrust = @health_ccw = @health_cw = 1.0
      @health_north = @health_south = @health_east = @health_west = 1.0
    end

    def initialize_data_collection
      @facing = :north
      @data = 0
      @data_source = nil
      @data_blocks = []
      @data_block_count = 6
    end

    def initialize_control_flags
      @is_player = true
      @player_control = true
      @is_rotating = false
      @is_effectable = true
      @is_interfacing = false
      @is_dooring = false
    end

    def initialize_emp_system
      @emp_storage = 1
      @emp_count = 1
    end

    def initialize_ui_elements
      bar_w = HuskGame::Constants::PROGRESS_BAR_WIDTH
      @data_progress = ExampleApp::ProgressBar.new(:data_progress, bar_w, 0, :white)
      @data_progress.x = HuskGame::Constants::SCREEN_WIDTH - HuskGame::Constants::VIEWSCREEN_BORDER - bar_w
      @data_progress.y = HuskGame::Constants::PROGRESS_BAR_Y_DATA
      @data_progress.view_actual_size!
    end

    def initialize_inventory
      @inventory = []
    end

    public

    def ramp_factor(axis)
      t = (@thrust_hold[axis].to_f / THRUST_RAMP_FRAMES).clamp(0.0, 1.0)
      # t * t * t # cubic ease-in
      t * t # quartic ease-in
    end

    def speed_factor(axis)
      max = MAX_SPEED[@scale]
      current = @momentum[axis].abs
      (1.0 - (current.to_f / max)).clamp(0.1, 1.0)
    end

    def thrust_factor(axis, input)
      if input != 0
        @thrust_hold[axis] += 1
      else
        @thrust_hold[axis] = 0
      end
      ramp_factor(axis) * speed_factor(axis)
    end

    def add_thrust_x input
      health_multiplier = input < 0 ? @health_west : @health_east
      @energy.x += input * @thrust * health_multiplier * SCALED_THRUST[@scale] * thrust_factor(:x, input)
    end
    def add_thrust_y input
      health_multiplier = input < 0 ? @health_south : @health_north
      @energy.y += input * @thrust * health_multiplier * SCALED_THRUST[@scale] * thrust_factor(:y, input)
    end
    def add_thrust x=0, y=0
      health_multiplier_x = x < 0 ? @health_west : @health_east
      health_multiplier_y = y < 0 ? @health_south : @health_north
      @energy.x += x * @thrust * health_multiplier_x * SCALED_THRUST[@scale] * thrust_factor(:x, x)
      @energy.y += y * @thrust * health_multiplier_y * SCALED_THRUST[@scale] * thrust_factor(:y, y)
    end

    def calc_rotation
      @angle += @momentum.rotation
    end

    # Shared method to calculate position along an axis
    private def calc_position_axis(axis)
      momentum = @momentum[axis]
      energy = @energy[axis]
      effect = @effect[axis]
      position = axis == :x ? @x : @y

      # Update momentum and position
      momentum += energy
      momentum += effect if @is_effectable
      position += momentum
      position.truncate

      # Update instance variables
      @momentum[axis] = momentum
      if axis == :x
        @x = position
      else
        @y = position
      end

      # Render thrust sprites
      update_thrust_sprites(axis, energy)

      # Reset the movement
      @effect[axis] = 0
      @energy[axis] = 0
    end

    private def update_thrust_sprites(axis, energy)
      if axis == :x
        if energy < 0
          @current_sprite_hash[:thrusteast].path = \
            HuskGame::AssetPaths::Sprites.ship_thrust_sprite("east", @scale, energy.abs.clamp(0, HuskGame::Constants::THRUST_MAX_POWER_LEVEL).truncate)
        elsif energy > 0
          @current_sprite_hash[:thrustwest].path = \
            HuskGame::AssetPaths::Sprites.ship_thrust_sprite("west", @scale, energy.clamp(0, HuskGame::Constants::THRUST_MAX_POWER_LEVEL).truncate)
        else
          @current_sprite_hash[:thrusteast].path = HuskGame::AssetPaths::Sprites.ship_thrust_sprite("east", @scale)
          @current_sprite_hash[:thrustwest].path = HuskGame::AssetPaths::Sprites.ship_thrust_sprite("west", @scale)
        end
      else # axis == :y
        if energy < 0
          @current_sprite_hash[:thrustnorth].path = \
            HuskGame::AssetPaths::Sprites.ship_thrust_sprite("north", @scale, energy.abs.clamp(0, HuskGame::Constants::THRUST_MAX_POWER_LEVEL).truncate)
        elsif energy > 0
          @current_sprite_hash[:thrustsouth].path = \
            HuskGame::AssetPaths::Sprites.ship_thrust_sprite("south", @scale, energy.clamp(0, HuskGame::Constants::THRUST_MAX_POWER_LEVEL).truncate)
        else
          @current_sprite_hash[:thrustnorth].path = HuskGame::AssetPaths::Sprites.ship_thrust_sprite("north", @scale)
          @current_sprite_hash[:thrustsouth].path = HuskGame::AssetPaths::Sprites.ship_thrust_sprite("south", @scale)
        end
      end
      refresh_sprites
    end

    public def calc_position_x
      calc_position_axis(:x)
    end

    def predict_position_y
      new_momentum_y = @momentum.y + @energy.y
      new_momentum_y += @effect.y if @is_effectable
      new_y = @y + new_momentum_y
      new_y.truncate
    end

    def calc_position_y
      calc_position_axis(:y)
    end

    def momentum_magnitude
      $gtk.args.geometry.vec2_magnitude @momentum
    end
    def relative_speed
      (momentum_magnitude * HuskGame::Constants::RELATIVE_SPEED_MULTIPLIER).clamp(0, 1)
    end

    def rotate_ccw
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
      face_turn_ccw
      @is_rotating = false
    end

    def rotate_cw
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
    end

    # Checking if we need this
    # TODO: uncomment or delete
    # def bounce_x_off off
    #   if @x > off.x
    #     right_edge = off.x + off.w
    #     @x = right_edge + (right_edge - @x)
    #     @momentum.x *= -off.bounce
    #   elsif x < off.x
    #     @x -= (@x + @w - off.x)
    #     @momentum.x *= -off.bounce
    #   end
    # end
    #
    # def bounce_y_off off
    #   puts 'bounce_y_off'
    #   puts off
    #   if @y > off.y
    #     @y -= (@y - @h - off.y)
    #     @momentum.y *= -off.bounce
    #   elsif @y < off.y
    #     @y -= (@y + @h - off.y)
    #     @momentum.y *= -off.bounce
    #   end
    # end

    def switch_rooms scale
      set_scale scale
      @current_sprite_hash[:turret].angle = FACING_KEYED[@facing] * 90
    end

    def boost_thrust amount=10, duration=3.seconds, start_duration=10
      current_thrust = @thrust

      run_action(
        Zif::Actions::Sequence.new(
          [
            new_action({thrust: current_thrust + amount}, duration: start_duration, easing: :smooth_start) {},

            new_action({thrust: current_thrust}, duration: duration, easing: :smooth_stop) {}
          ]
        )
      )
    end

    def change_health amount, side
      play_voiceover(HuskGame::AssetPaths::Audio::VOICE_DRONE_DAMAGED)

      case side
      when :north
        @health_north = (@health_north += amount).clamp(0, 1.0)
      when :south
        @health_south = (@health_south += amount).clamp(0, 1.0)
      when :east
        @health_east = (@health_east += amount).clamp(0, 1.0)
      when :west
        @health_west = (@health_west += amount).clamp(0, 1.0)
      end
    end


    def add_data(amount, source: nil)
      if source && source != @data_source
        @data = 0
        @data_progress.progress = 0
        @data_source = source
      end
      @data += amount
      @data_progress.progress = @data * 0.001 # inverse of default terminal data (1000)
    end

    def add_data_block_slot(amount = 1)
      @data_block_count += amount
    end

    def add_data_block(name:, size:, corrupted:)
      if @data_blocks.length < @data_block_count
        @data_blocks << {name: name, size: size, corrupted: corrupted}
      end
      @data = 0
      @data_source = nil
      @data_progress.progress = 0
    end

    def purge_data_blocks
      @data_blocks.clear
      @data = 0
      @data_source = nil
      @data_progress.progress = 0
    end

    def add_data_core
      if @data_core == :empty
        @data_core = :full
        # Make a good noise or something
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_DATA_CORE_COLLECTED)
      elsif @data_core == :full || @data_core == :overloaded
        @data_core = :overloaded
        # Make a bad noise
        play_voiceover(HuskGame::AssetPaths::Audio::VOICE_DATA_CORE_OVERLOADED)
      end
    end

    def render_data_blocks
      output = []
      @data_block_count.times do |i|
        output.concat(render_single_data_block(i))
      end
      output
    end

    private

    def render_single_data_block(index)
      x_offset = 600
      y_offset = 40
      block_height = 40
      block_width = 96
      block_draw_height = 32

      corruption_status = get_block_corruption_status(index)
      color_value = data_block_color(corruption_status)

      y_position = (block_height * index) + y_offset

      [
        create_data_block_solid(x_offset, y_position, block_width, block_draw_height, color_value),
        create_data_block_border(x_offset, y_position, block_width, block_draw_height)
      ]
    end

    def get_block_corruption_status(index)
      data = @data_blocks[index]
      data&.fetch(:corrupted, nil)
    end

    def data_block_color(corrupted)
      case corrupted
      when true then 180    # Corrupted - dim orange
      when false then 250   # Valid - bright green
      else 32               # Empty - very dark
      end
    end

    def create_data_block_solid(x, y, w, h, color_value)
      {
        x: x,
        y: y,
        w: w,
        h: h,
        r: color_value - 16,
        g: color_value,
        b: color_value - 16,
        primitive_marker: :solid
      }
    end

    def create_data_block_border(x, y, w, h)
      {
        x: x,
        y: y,
        w: w,
        h: h,
        r: 255,
        g: 255,
        b: 255,
        primitive_marker: :border
      }
    end

    public

    def emp_count=(c)
      @emp_count = c.clamp(0, @emp_storage)
    end

    def has_item?(item)
      @inventory.include?(item)
    end
    def add_item(item)
      @inventory << item
    end

    def to_s
      {
        name: @name,
        health_north: @health_north,
        health_south: @health_south,
        health_east: @health_east,
        health_west: @health_west,
        emp_count: @emp_count,
        data_block_count: @data_block_count,
        data_blocks: @data_blocks,
      }.to_s
    end
  end
end