module HuskGame
  class HunterBlob < HuskSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Boundable
    include HuskEngine::Scaleable
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
    DEFAULT_SPEED = 18
    MOMENTUM_DAMPING = 0.8
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

      # mark_and_print("initialize")

      set_position(x, y)
      initialize_deadable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_tickable
      initialize_stateable("agent")
      build_state_transitions

      initialize_empable
      @emp_low = EMP_LOW
      @emp_medium = EMP_MEDIUM

      @alert_threshold = ALERT_DISTANCE
      @sound_collide = "sounds/thump.wav"
      @audio_idle = "sounds/hunterblob.wav"

      @default_speed = @current_speed = DEFAULT_SPEED
      @momentum = {
        x: 0,
        y: 0
      }
    end

    def perform_tick
      return unless @active

      spatialize(@name.to_sym)

      ship_xy = $gtk.args.state.ship.xy
      dx = ship_xy.x - @x
      dy = ship_xy.y - @y
      dist_sq = dx * dx + dy * dy
      alert_sq = @alert_threshold * @alert_threshold

      if dist_sq > alert_sq
        change_state(:idle)
        return
      end

      change_state(:hunting) if @state == :idle

      dist = Math.sqrt(dist_sq)
      diff_normalized = $gtk.args.geometry.vec2_normalize({ x: dx, y: dy })
      diff_scaled = diff_normalized.merge(diff_normalized) { |_k, v| v * (1 / dist) }

      @momentum.x += diff_scaled[:x] * @current_speed
      @momentum.y += diff_scaled[:y] * @current_speed

      @x += @momentum[:x]
      @y += @momentum[:y]

      bounds_inside(HuskGame::Constants::VIEWSCREEN)

      @momentum[:x] *= MOMENTUM_DAMPING
      @momentum[:y] *= MOMENTUM_DAMPING

      current_speed = @current_speed + 1 unless @state == :damaged
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