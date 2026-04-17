module HuskGame
  class HunterBlob < HuskSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Boundable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Empable
    include HuskEngine::Stateable

    attr_accessor :momentum

    sprite_data 'hunterblob'

    state_machine(
      idle:     [:hunting],
      hunting:  [:idle, :damaged, :dead],
      damaged:  [:idle, :hunting, :dead],
      dead:     []
    )

    BLOWBACK_SCALES = {
      large: 6,
      medium: 4,
      small: 3,
      tiny: 2
    }.freeze

    ALERT_DISTANCE = 300
    DEFAULT_SPEED = 10
    MOMENTUM_DAMPING = 0.8
    TRAIL_DELAY = 90  # ticks behind the player (~1.5 seconds)
    TRAIL_SIZE = 120  # max positions stored
    EMP_LOW = 60
    EMP_MEDIUM = 120
    EMP_SPEED_DIVISOR_LOW = 20
    EMP_SPEED_DIVISOR_MEDIUM = 15

    def initialize(
      x: 360,
      y: 960,
      scale: :large
    )
      @tracer_service_name = :tracer
      super(Zif.unique_name("HunterBlob"))

      set_position(x, y)
      initialize_deadable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bufferable(:single)
      initialize_tickable
      initialize_stateable("agent")
      build_state_transitions

      initialize_empable
      @emp_low = EMP_LOW
      @emp_medium = EMP_MEDIUM

      @alert_threshold = ALERT_DISTANCE
      @sound_collide = HuskGame::AssetPaths::Audio::THUMP
      @audio_idle = HuskGame::AssetPaths::Audio::HUNTER_BLOB_IDLE

      @default_speed = @current_speed = DEFAULT_SPEED
      @momentum = {
        x: 0,
        y: 0
      }

      @trail = []
    end

    def perform_tick
      return unless @active

      spatialize(@name.to_sym)

      ship = $gtk.args.state.ship
      record_trail(ship)
      target = delayed_target(ship)

      dx = target[:x] - @x
      dy = target[:y] - @y
      dist_sq = dx * dx + dy * dy
      alert_sq = @alert_threshold * @alert_threshold

      if dist_sq > alert_sq
        change_state(:idle)
        return
      end

      change_state(:hunting) if @state == :idle

      dist = Math.sqrt(dist_sq)
      # Close enough to target — drift idle until trail advances
      if dist < 4
        @momentum[:x] *= MOMENTUM_DAMPING
        @momentum[:y] *= MOMENTUM_DAMPING
        return
      end

      diff_normalized = $gtk.args.geometry.vec2_normalize({ x: dx, y: dy })
      # Scale force by inverse distance, clamped to prevent spikes up close
      force = @current_speed / dist.clamp(30, ALERT_DISTANCE)

      @momentum.x += diff_normalized[:x] * force
      @momentum.y += diff_normalized[:y] * force

      @x += @momentum[:x]
      @y += @momentum[:y]

      bounds_inside(HuskGame::Constants::VIEWSCREEN)

      @momentum[:x] *= MOMENTUM_DAMPING
      @momentum[:y] *= MOMENTUM_DAMPING

      current_speed = @current_speed + 1 unless @state == :damaged
    end

    def record_trail(ship)
      @trail << { x: ship.x, y: ship.y }
      @trail.shift if @trail.length > TRAIL_SIZE
    end

    def delayed_target(ship)
      delay_index = @trail.length - TRAIL_DELAY
      return @trail[delay_index] if delay_index >= 0
      # Trail not long enough yet — target oldest known position
      @trail.first || { x: ship.x, y: ship.y }
    end

    def collide_action collidee, facing
      collidee.add_data_block(name: 'hunterblob', size: 1, corrupted: true)

      blowback = BLOWBACK_SCALES[@scale]

      case facing
      when :north
        collidee.momentum.y += blowback
      when :south
        collidee.momentum.y += -blowback
      when :east
        collidee.momentum.x += blowback
      when :west
        collidee.momentum.x += -blowback
      end

      change_state(:dead)
    end

    def current_speed=(speed)
      @current_speed = speed.clamp(0, @default_speed)
    end

    def handle_emp_low(emp_level)
      self.current_speed = @current_speed - emp_level.idiv(EMP_SPEED_DIVISOR_LOW)
    end

    def handle_emp_medium(emp_level)
      self.current_speed = @current_speed - emp_level.idiv(EMP_SPEED_DIVISOR_MEDIUM)
      change_state(:damaged)
    end

    def handle_emp_high(_emp_level)
      change_state(:dead)
    end

    def on_dead
      kill
    end
  end
end