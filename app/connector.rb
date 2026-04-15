module HuskGame
  class Connector < HuskSprite
    include Zif::Traceable
    include HuskEngine::Collideable
    include HuskEngine::Scaleable
    include HuskEngine::Faceable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Shadowable
    include HuskEngine::Empable
    include HuskEngine::Stateable


    DATA_STAGE_TWO_THIRDS = 0.667
    DATA_STAGE_ONE_THIRD = 0.333
    DATA_HOLD_TICKS = 10
    CONNECTOR_BOUNCE = 0.3
    EMP_LOW_DATA_MULTIPLIER = 0.8
    EMP_MEDIUM_DATA_MULTIPLIER = 0.5

    attr_reader :interfacing, :data, :data_rate, :tolerance
    attr_reader :audio_idle

    def indicator_layer_name
      "lights"
    end

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
      initialize_bounceable(sound_bounce: HuskGame::AssetPaths::Audio::THUMP)
      initialize_bufferable(:double)
      initialize_tickable
      initialize_empable
      initialize_stateable(:connectors)

      # variable assign
      @facing = facing
      rotate_sprites(@facing)

      @interfacing = false
      @data = data
      @remaining_data = data
      @stage = :full
      @corrupted = false
      @data_rate = data_rate
      raise(StandardError, "Connector initialization data_rate is zero!") if data_rate <= 0
      @data_hold_time = DATA_HOLD_TICKS
      @tolerance = tolerance

      # @bounce = 0.7
      @sound_collide = HuskGame::AssetPaths::Audio::THUMP

      @sound_pickup_success = HuskGame::AssetPaths::Audio::PICKUP
      @audio_idle = HuskGame::AssetPaths::Audio::DATA_TERMINAL_IDLE
    end

    def collide_action(collidee, collided_on)
      # puts "Connector: collidee facing: #{collidee.facing}, collide_action: #{collided_on}, facing: #{@facing}, remaining: #{@remaining_data}"
      # puts "previous_tick: #{@previous_data_tick}"

      # Get the turret direction from the player
      # and compare it to the collision facing
      if HuskEngine::Faceable.facing_opposite?(collidee.facing, collided_on) &&
        collided_on == @facing && @remaining_data > 0

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

        if aligned_with?(collidee, @facing, @tolerance)
          @previous_data_tick ||= Kernel.tick_count

          # If the data isn't collected all in one go, there is a chance the data gets corrupted.
          # if Kernel.tick_count - @previous_data_tick <= @data_hold_time
          if Kernel.tick_count - @previous_data_tick >= @data_hold_time
            @corrupted |= rand(3) == 0
            mark_and_print "Has been corrupted? #{@corrupted}"
          end

          @interfacing = true
          # puts "interfacing: #{@interfacing}, data_rate: #{@data_rate}"

          collidee.add_data(@data_rate, source: self)

          reduce_data @data_rate

          if @remaining_data <= 0
            on_data_depleted(collidee)
          end

          @previous_data_tick = Kernel.tick_count
        end # entering
      else
        # play_once @sound_collide
        bounce_off(collidee, collided_on)
      end
    end

    def on_data_depleted(collidee)
      collidee.add_data_block(name: @name, size: @data, corrupted: @corrupted)
      audio_feedback = @corrupted ? HuskGame::AssetPaths::Audio::VOICE_DATA_CORRUPTED : HuskGame::AssetPaths::Audio::VOICE_DATA_COLLECTED
      play_voiceover audio_feedback
      # turn off the audio
      @audio_idle = nil
      $gtk.args.audio[@name.to_sym] = nil
    end

    def reduce_data(data=nil)
      @remaining_data -= data

      indicator = @sprites.find { |s| s.name == "#{class_name}_#{indicator_layer_name}_#{scale}" }

      if @stage == :full && @remaining_data <= (@data * DATA_STAGE_TWO_THIRDS).truncate
        @stage = :two_thirds
        indicator&.assign(
          {path: "sprites/#{class_name}/#{class_name}_#{indicator_layer_name}_#{@scale.to_s}_2.png"}
        )
      elsif @stage == :two_thirds && @remaining_data <= (@data * DATA_STAGE_ONE_THIRD).truncate
        @stage = :one_third
        indicator&.assign(
          {path: "sprites/#{class_name}/#{class_name}_#{indicator_layer_name}_#{@scale.to_s}_1.png"}
        )
      end

      if @remaining_data <= 0
        indicator&.hide
      end
    end

    def perform_tick
      # puts "CONNECTOR PERFORM_TICK"
      spatialize(@name.to_sym)
      perform_shadow_tick
    end

    def bounce
      CONNECTOR_BOUNCE
    end

    def handle_emp_low emp_level
      @remaining_data *= EMP_LOW_DATA_MULTIPLIER
    end
    def handle_emp_medium emp_level
      @remaining_data *= EMP_MEDIUM_DATA_MULTIPLIER
      @corrupted |= rand(3) == 0
    end
    def handle_emp_high emp_level
      @remaining_data = 0
      indicator = @sprites.find { |s| s.name == "#{class_name}_#{indicator_layer_name}_#{scale}" }
      indicator&.hide
    end
  end
end
