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
    # mark_and_print "Prepare Scene: Splash Scene END"
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

    if @current_scene_tick == 180
      @splash.run_action(
        @splash.new_action({a: 0}, duration: 1.seconds, easing: :smooth_step3) { @next_scene = :room }
      )
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
    # puts "tick: #{@current_scene_tick}"
    # mark_and_print("tick: #{@current_scene_tick}")
    @current_scene_tick += 1
    # return :room if @current_scene_tick > 200
    return @next_scene
  end
end
