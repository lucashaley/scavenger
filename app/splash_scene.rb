class SplashScene < Zif::Scene
  include Zif::Traceable

  def initialize
    super()
    @tracer_service_name = :tracer

    # mark_and_print("initialize")

    @current_scene_tick = 0
    @started = false
    @next_scene = nil
  end

  def prepare_scene
    # mark_and_print "Prepare Scene: Splash Scene"
    @splash = Zif::Sprite.new.tap do |s|
      s.w = 720
      s.h = 1280
      s.path = 'sprites/splash.png'
      s.a = 0
    end
    $game.services[:action_service].register_actionable(@splash)

    # @bg_music =
    $gtk.args.audio[:splash_music] ||= {
      input: "music/Lucas_HuskGame_intro_DnB.wav",
      looping: true,
      gain: 0
    }
    @audio_fade = false
  end

  def perform_tick
    # mark_and_print "perform_tick START"
    unless @started
      @splash.run_action(
        @splash.new_action({a: 255}, duration: 1.seconds, easing: :smooth_step3)
      )
      @splash.run_action(
        @splash.new_action({x: -10, y: -10, w: 740, h: 1300}, duration: 4.seconds, easing: :smooth_step3)
      )
      @started = true
    end

    unless @audio_fade
      if $gtk.args.audio[:splash_music] && $gtk.args.audio[:splash_music].gain < 1.0
        # increase the gain 1% every tick until we are at 100%
        $gtk.args.audio[:splash_music].gain += 0.3
        # clamp value to 1.0 max value
        $gtk.args.audio[:splash_music].gain = 1.0 if $gtk.args.audio[:splash_music].gain > 1.0
      end
    else
      if $gtk.args.audio[:splash_music] && $gtk.args.audio[:splash_music].gain > 0.0
        # increase the gain 1% every tick until we are at 100%
        $gtk.args.audio[:splash_music].gain -= 0.01667
        # clamp value to 1.0 max value
        $gtk.args.audio[:splash_music].gain = 0.0 if $gtk.args.audio[:splash_music].gain < 0.0
      end
    end

    if @current_scene_tick == 300 || $gtk.args.inputs.mouse.click
      # @splash.run_action(
      #   @splash.new_action({a: 0}, duration: 1.seconds, easing: :smooth_step3) { @next_scene = :room }
      # )
      exit_splash
    end

    $gtk.args.outputs.solids << {
      x:    0,
      y:    0,
      w:  720,
      h:  1280,
      r:    0,
      g:  0,
      b:    0,
      a:  255,
      anchor_x: 0,
      anchor_y: 0,
      blendmode_enum: 1
    }

    $gtk.args.outputs.sprites << [
      @splash
    ]
    @current_scene_tick += 1
    return @next_scene
  end

  def exit_splash
    @splash.run_action(
      @splash.new_action({a: 0}, duration: 1.seconds, easing: :smooth_step3) do
        $gtk.args.audio[:splash_music] = nil
        @next_scene = :room
      end
    )
    @audio_fade = true
  end
end
