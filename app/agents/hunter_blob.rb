module HuskGame
  class HunterBlob < Zif::CompoundSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Scaleable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Empable

    attr_accessor :momentum

    SPRITE_DETAILS = {
      name: "hunterblob",
      layers: [
        name: "main",
        blendmode_enum: :alpha,
        z: 0
      ],
      scales: {
        large: {
          w: 64,
          h: 64
        },
        medium: {
          w: 32,
          h: 32
        },
        small: {
          w: 16,
          h: 16
        }
      }
    }.freeze

    def initialize(
      x: 360,
      y: 960,
      scale: :large
    )
      @tracer_service_name = :tracer
      super(Zif.unique_name("HunterBlob"))

      # mark_and_print("initialize")

      set_position(x, y)
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_tickable

      initialize_empable
      @emp_low = 100
      @emp_medium = 240

      @alert_threshold = 300
      @sound_collide = "sounds/thump.wav"
      @audio_idle = "sounds/hunterblob.wav"

      @default_speed = @current_speed = 18
      @momentum = {
        x: 0,
        y: 0
      }
      @damaged = false
    end

    def perform_tick
      return unless @active

      spatialize(@name.to_sym) if @active

      dist = $gtk.args.geometry.distance($gtk.args.state.ship.xy, self.xy).abs
      return if dist > @alert_threshold

      diff_array = Zif.sub_positions($gtk.args.state.ship.xy, self.xy)
      diff_normalized = $gtk.args.geometry.vec2_normalize({
        x: diff_array[0],
        y: diff_array[1]
      })
      # puts diff_normalized
      # diff_scaled = diff_normalized.map { |k,v| k: v * (1/dist) }
      diff_scaled = diff_normalized.merge(diff_normalized) {|k,v| v*(1/dist) }
      # puts diff_scaled

      @momentum.x += diff_scaled[:x] * @current_speed
      @momentum.y += diff_scaled[:y] * @current_speed

      @x += @momentum[:x]
      @y += @momentum[:y]

      # This is copypasta from Ship
      # And has totally not been tested, because how can I make it go out of bounds?
      if @x + @w > $ui_viewscreen.right
        @x -= (@x + @w - $ui_viewscreen.right)
        @momentum.x *= -1.0
      elsif @x < $ui_viewscreen.left
        @x += $ui_viewscreen.left - @x
        @momentum.x *= -1.0
      end
      if @y + @h > $ui_viewscreen.top
        @y -= (@y + @h - $ui_viewscreen.top)
        @momentum.y *= -1.0
      elsif @y < $ui_viewscreen.bottom
        @y += $ui_viewscreen.bottom - @y
        @momentum.y *= -1.0
      end

      @momentum[:x] *= 0.8
      @momentum[:y] *= 0.8

      current_speed = @current_speed + 1 unless @damaged
    end

    def collide_action collidee, facing
      mark_and_print ("Collide with HunterBlob!")
      puts "facing: #{facing}"
      collidee.add_data_block(name: 'hunterblob', size: 1, corrupted: true)

      blowback = 6

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

      kill
    end

    def current_speed=(speed)
      puts "assigning speed: #{speed}"
      @current_speed = speed.clamp(0, @default_speed)
    end

    def handle_emp_low emp_level
      self.current_speed = @current_speed - emp_level.idiv(20)
      puts @current_speed
    end
    def handle_emp_medium emp_level
      self.current_speed = @current_speed - emp_level.idiv(15)
      @damaged = true
      puts @current_speed
    end
    def handle_emp_high emp_level
      kill
    end
  end
end