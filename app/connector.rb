module HuskGame
  class Connector < Zif::CompoundSprite
    include Zif::Traceable
    include HuskEngine::Collideable
    include HuskEngine::Bounceable
    include HuskEngine::Scaleable
    include HuskEngine::Faceable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Shadowable
    include HuskEngine::Empable


    attr_reader :interfacing, :data, :data_rate, :tolerance
    attr_accessor :audio_idle

    def initialize(
      x: 0,
      y: 0,
      scale: :large,
      facing: :south,
      tolerance: 4,
      data: 1000,
      data_rate: 2
    )
      @tracer_service_name = :tracer
      super(Zif.unique_name(class_name))

      set_position(x, y)

      # collate_sprites 'dataterminal' + facing.to_s
      # set_scale scale
      initialize_shadowable
      register_sprites_new
      initialize_scaleable(scale)
      initialize_collideable
      initialize_bounceable(bounce: 0.3, sound_bounce: 'sounds/thump.wav')
      initialize_bufferable(:double)
      initialize_tickable
      initialize_empable

      # variable assign
      @facing = facing
      rotate_sprites(@facing)

      @interfacing = false
      @data = data
      @remaining_data = data
      @corrupted = false
      @data_rate = data_rate
      raise(StandardError, "Connector initialization data_rate is zero!") if data_rate <= 0
      @data_hold_time = 10
      @tolerance = tolerance

      @bounce = 0.7
      @sound_collide = "sounds/thump.wav"

      @sound_pickup_success = "sounds/pickup.wav"
      @audio_idle = 'sounds/dataterminal_idle.wav'
    end

    def collide_action(collidee, collided_on)
      # puts "Connector: collidee facing: #{collidee.facing}, collide_action: #{collided_on}, facing: #{@facing}, remaining: #{@remaining_data}"
      # puts "previous_tick: #{@previous_data_tick}"

      # Get the turret direction from the player
      # and compare it to the collision facing
      if ((collidee.facing == :north && collided_on == :south && @facing == :south) ||
        (collidee.facing == :south && collided_on == :north && @facing == :north) ||
        (collidee.facing == :west && collided_on == :east && @facing == :east) ||
        (collidee.facing == :east && collided_on == :west && @facing == :west)) && @remaining_data > 0

        # This stops the overlap and bounce, and the weird y collision stuff
        # This would all be easier if we did predictive collision, instead of reactive
        case @facing
        when :north
          collidee.y = @y + @h
          collidee.momentum.y = 0.0
        when :south
          collidee.y = @y - collidee.h
          collidee.momentum.y = 0.0
        when :east
          collidee.x = @x + @w
          collidee.momentum.x = 0.0
        when :west
          collidee.x = @x - collidee.w
          collidee.momentum.x = 0.0
        end

        # This is ripped from the door
        # Possible chance of optimization/refactor
        puts "tolerance: #{@tolerance}"
        entering = case @facing
                   when :north, :south
                     collidee.center_x.between?(center_x - @tolerance, center_x + @tolerance)
                   when :east, :west
                     collidee.center_y.between?(center_y - @tolerance, center_y + @tolerance)
                   end
        puts "entering: #{entering}"
        if entering
          @previous_data_tick ||= Kernel.tick_count

          # If the data isn't collected all in one go, there is a chance the data gets corrupted.
          # if Kernel.tick_count - @previous_data_tick <= @data_hold_time
          if Kernel.tick_count - @previous_data_tick >= @data_hold_time
            @corrupted |= rand(3) == 0
            mark_and_print "Has been corrupted? #{@corrupted}"
          end

          @interfacing = true
          puts "interfacing: #{@interfacing}, data_rate: #{@data_rate}"

          collidee.add_data(@data_rate)
          # @data -= @data_rate
          @remaining_data -= @data_rate

          # Update the lights sprite
          # TODO: put this in a method, as we change the values elsewhere
          if @remaining_data == (@data * 0.667).truncate
            puts "TWO THIRDS!"
            puts @sprites
            @sprites.find { |s| s.name == "dataterminal_lights_#{scale}" }.assign(
              {path: "sprites/dataterminal/dataterminal_lights_#{@scale.to_s}_2.png"}
            )
          elsif @remaining_data == (@data * 0.333).truncate
            puts "ONE THIRD"
            @sprites.find { |s| s.name == "dataterminal_lights_#{scale}" }.assign(
              {path: "sprites/dataterminal/dataterminal_lights_#{@scale.to_s}_1.png"}
            )
          end


          if @remaining_data <= 0
            # the data block has been collected
            @sprites.find { |s| s.name == "dataterminal_lights_#{scale}" }.hide

            collidee.add_data_block(name: @name, size: @data, corrupted: @corrupted)
            audio_feedback = @corrupted ? "sounds/data_corrupted.wav" : "sounds/data_collected.wav"
            play_once audio_feedback
          end

          @previous_data_tick = Kernel.tick_count
        else
          puts "missed!"
        end # entering
      else
        # play_once @sound_collide
        bounce_off(collidee, collided_on)
      end
    end

    def perform_tick
      # puts "CONNECTOR PERFORM_TICK"
      spatialize(@name.to_sym)
      perform_shadow_tick
    end

    def handle_emp_low emp_level
      puts "Connector: handle_emp_low"
      @remaining_data *= 0.8
    end
    def handle_emp_medium emp_level
      puts "Connector: handle_emp_medium"
      @remaining_data *= 0.5
      @corrupted |= rand(3) == 0
    end
    def handle_emp_high emp_level
      puts "Connector: handle_emp_high"
      @remaining_data = 0
      @sprites.find { |s| s.name == "dataterminal_lights_#{scale}" }.hide
    end
  end
end
