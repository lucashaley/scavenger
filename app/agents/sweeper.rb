module HuskGame
  class Sweeper < HuskSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Shadowable
    include HuskEngine::Tickable
    include HuskEngine::Empable
    include HuskEngine::Stateable
    include HuskGame::Roomable

    sprite_data 'sweeper'

    state_machine(
      sweeping: [:stopped, :disabled],
      stopped:  [:sweeping, :disabled],
      disabled: []
    )

    SPEED = 1
    SHIFT_AMOUNT = {
      large:  4,
      medium: 3,
      small:  2,
      tiny:   1
    }.freeze
    SHIP_DAMAGE = -0.15
    STOP_MIN_TICKS = 60   # 1 second
    STOP_MAX_TICKS = 180  # 3 seconds
    EMP_LOW = 60
    EMP_MEDIUM = 120

    PERPENDICULAR = { horizontal: :vertical, vertical: :horizontal }.freeze

    def initialize(x: 360, y: 960, scale: :large, room: nil, axis: nil)
      @tracer_service_name = :tracer
      super(Zif.unique_name("Sweeper"))
      set_position(x, y)
      initialize_shadowable
      initialize_deadable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bounceable
      initialize_bufferable(:single)
      initialize_tickable
      initialize_stateable("agent", initial_state: :sweeping)
      build_state_transitions
      initialize_empable
      initialize_roomable(room) if room
      @emp_low = EMP_LOW
      @emp_medium = EMP_MEDIUM
      @sound_collide = HuskGame::AssetPaths::Audio::THUMP

      # Movement state
      @primary_axis = axis || [:horizontal, :vertical].sample
      @primary_direction = [-1, 1].sample
      @perp_direction = [-1, 1].sample
      @speed = SPEED
      @stop_timer = 0

      # initialize animation
      animation_name = "sweeper_base_#{scale}"
      @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)
    end

    def perform_tick
      return unless @active
      spatialize(@name.to_sym)
      perform_shadow_tick
      return if @state == :disabled

      if @state == :stopped
        @stop_timer -= 1
        change_state(:sweeping) if @stop_timer <= 0
        return
      end

      move
    end

    def move
      scale_px = HuskGame::Constants::SPRITE_SCALES[@scale]
      vs = HuskGame::Constants::VIEWSCREEN

      if @primary_axis == :horizontal
        next_x = @x + (@speed * @primary_direction)
        if next_x < vs[:left] + scale_px || next_x + scale_px > vs[:right] - scale_px || obstacle_at?(next_x, @y)
          shift_perpendicular
          @primary_direction *= -1
        else
          @x = next_x
        end
      else
        next_y = @y + (@speed * @primary_direction)
        if next_y < vs[:bottom] + scale_px || next_y + scale_px > vs[:top] - scale_px || obstacle_at?(@x, next_y)
          shift_perpendicular
          @primary_direction *= -1
        else
          @y = next_y
        end
      end

      check_ship_collision
    end

    def check_ship_collision
      ship = $gtk.args.state.ship
      return unless ship
      return unless $gtk.args.geometry.intersect_rect?(self, ship)

      # Determine which side of the ship we hit
      dx = ship.x - @x
      dy = ship.y - @y
      facing = dx.abs > dy.abs ? (dx > 0 ? :west : :east) : (dy > 0 ? :south : :north)

      collide_action(ship, facing)
    end

    def shift_perpendicular
      scale_px = HuskGame::Constants::SPRITE_SCALES[@scale]
      vs = HuskGame::Constants::VIEWSCREEN
      shift = SHIFT_AMOUNT[@scale]

      if @primary_axis == :horizontal
        next_y = @y + (shift * @perp_direction)
        if blocked_y?(next_y, scale_px, vs)
          @perp_direction *= -1
          next_y = @y + (shift * @perp_direction)
          return if blocked_y?(next_y, scale_px, vs)
        end
        @y = next_y
      else
        next_x = @x + (shift * @perp_direction)
        if blocked_x?(next_x, scale_px, vs)
          @perp_direction *= -1
          next_x = @x + (shift * @perp_direction)
          return if blocked_x?(next_x, scale_px, vs)
        end
        @x = next_x
      end
    end

    def blocked_x?(test_x, scale_px, vs)
      test_x < vs[:left] + scale_px || test_x + scale_px > vs[:right] - scale_px || obstacle_at?(test_x, @y)
    end

    def blocked_y?(test_y, scale_px, vs)
      test_y < vs[:bottom] + scale_px || test_y + scale_px > vs[:top] - scale_px || obstacle_at?(@x, test_y)
    end

    def obstacle_at?(test_x, test_y)
      return false unless @room

      scale_px = HuskGame::Constants::SPRITE_SCALES[@scale]
      test_rect = { x: test_x, y: test_y, w: scale_px, h: scale_px }
      other_agents = @room.agents.reject { |a| a == self || a.is_dead? }
      obstacles = @room.dressings + @room.terminals + other_agents
      $gtk.args.geometry.find_intersect_rect(test_rect, obstacles) != nil
    end

    def collide_action(collidee, facing)
      bounce_off(collidee, facing)
      collidee.change_health(SHIP_DAMAGE, facing)
      play_once @sound_collide
      stop_temporarily
    end

    def stop_temporarily
      change_state(:stopped)
      @stop_timer = STOP_MIN_TICKS + rand(STOP_MAX_TICKS - STOP_MIN_TICKS)
    end

    def bounce
      HuskGame::Constants::HAZARD_BOUNCE
    end

    def handle_emp_low(_emp_level)
      # not affected by low EMP
    end

    def handle_emp_medium(_emp_level)
      change_state(:disabled)
    end

    def handle_emp_high(_emp_level)
      change_state(:disabled)
    end
  end
end
