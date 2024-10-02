module HuskGame
  class GameOverScene < Zif::Scene
    include Zif::Traceable

    def prepare_scene
      @tracer_service_name = :tracer
      @current_scene_tick = 0
      @started = false
      @next_scene = nil

      @black_background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid,
        r: 0, g: 0, b: 0, a: 255
      }
      $gtk.args.outputs.static_sprites << @black_background

      @game_over_image = Zif::Sprite.new.tap do |i|
        i.x = 0
        i.y = 0
        i.h = 1280
        i.w = 720
        i.a = 0
        i.path = 'sprites/ui_game_over.png'
      end
      $game.services[:action_service].register_actionable(@game_over_image)
      $gtk.args.outputs.static_sprites << @game_over_image

      $gtk.args.audio[:game_over_music] ||= {
        input: "music/Lucas_HuskGame_intro_DnB.wav",
        looping: true,
        gain: 0.5
      }
      @audio_fade = false
    end
    def perform_tick
      puts "GAME OVER"

      handle_meta_input
      handle_input

      unless @started
        @game_over_image.run_action(
          @game_over_image.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3)
        )
        @started = true
      end
    end

    def handle_meta_input
      $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q
    end

    def handle_input

    end
  end
end