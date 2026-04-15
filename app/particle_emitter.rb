module HuskEngine
  class ParticleEmitter
    attr_accessor :x, :y, :active, :rate, :direction
    attr_reader :particles

    # behavior: :explode, :attract, :swirl
    def initialize(
      x: 0, y: 0,
      rate: 1,
      lifetime: 30,
      speed_min: 1, speed_max: 3,
      size_start: 4, size_end: 1,
      color_start: { r: 255, g: 255, b: 255 },
      color_end: nil,
      alpha_start: 255, alpha_end: 0,
      behavior: :explode,
      direction: 0,
      spread: 360,
      blendmode_enum: :alpha,
      path: nil,
      target_x: nil, target_y: nil,
      swirl_radius: 30, swirl_speed: 0.1
    )
      @x = x
      @y = y
      @rate = rate
      @lifetime = lifetime
      @speed_min = speed_min
      @speed_max = speed_max
      @size_start = size_start
      @size_end = size_end
      @color_start = color_start
      @color_end = color_end || color_start
      @alpha_start = alpha_start
      @alpha_end = alpha_end
      @behavior = behavior
      @direction = direction
      @spread = spread
      @blendmode_enum = blendmode_enum
      @path = path
      @target_x = target_x
      @target_y = target_y
      @swirl_radius = swirl_radius
      @swirl_speed = swirl_speed
      @active = true
      @particles = []
    end

    def perform_tick
      emit if @active
      update_particles
      cull_dead
    end

    def emit
      @rate.times do
        @particles << spawn_particle
      end
    end

    def render
      @particles.map do |p|
        t = p[:age].fdiv(p[:lifetime]).clamp(0, 1)

        r = lerp(@color_start[:r], @color_end[:r], t)
        g = lerp(@color_start[:g], @color_end[:g], t)
        b = lerp(@color_start[:b], @color_end[:b], t)
        a = lerp(@alpha_start, @alpha_end, t)
        size = lerp(@size_start, @size_end, t)

        h = {
          x: p[:x] - size.half,
          y: p[:y] - size.half,
          w: size, h: size,
          r: r, g: g, b: b, a: a,
          blendmode_enum: @blendmode_enum
        }

        h[:path] = @path || :solid

        h
      end
    end

    private

    def spawn_particle
      half_spread = @spread * 0.5
      angle_deg = @direction + (rand * @spread) - half_spread
      angle_rad = angle_deg * Math::PI / 180.0
      speed = @speed_min + rand * (@speed_max - @speed_min)

      p = {
        x: @x.to_f,
        y: @y.to_f,
        age: 0,
        lifetime: @lifetime
      }

      case @behavior
      when :explode
        p[:vx] = Math.cos(angle_rad) * speed
        p[:vy] = Math.sin(angle_rad) * speed
      when :attract
        p[:vx] = Math.cos(angle_rad) * speed
        p[:vy] = Math.sin(angle_rad) * speed
        p[:target_x] = @target_x || @x
        p[:target_y] = @target_y || @y
      when :swirl
        p[:center_x] = @target_x || @x
        p[:center_y] = @target_y || @y
        p[:angle] = angle_rad
        p[:radius] = @swirl_radius
        p[:swirl_speed] = @swirl_speed
      end

      p
    end

    def update_particles
      @particles.each do |p|
        p[:age] += 1

        case @behavior
        when :explode
          p[:x] += p[:vx]
          p[:y] += p[:vy]
        when :attract
          dx = p[:target_x] - p[:x]
          dy = p[:target_y] - p[:y]
          dist = Math.sqrt(dx * dx + dy * dy)
          if dist > 1
            pull = 0.05
            p[:vx] += dx / dist * pull
            p[:vy] += dy / dist * pull
          end
          p[:x] += p[:vx]
          p[:y] += p[:vy]
        when :swirl
          p[:angle] += p[:swirl_speed]
          p[:x] = p[:center_x] + Math.cos(p[:angle]) * p[:radius]
          p[:y] = p[:center_y] + Math.sin(p[:angle]) * p[:radius]
        else
          # don't do anything
        end
      end
    end

    def cull_dead
      @particles.reject! { |p| p[:age] >= p[:lifetime] }
    end

    def lerp(a, b, t)
      a + (b - a) * t
    end
  end
end
