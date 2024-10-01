module HuskGame
  class GameCompleteScene < Zif::Scene
    def prepare_scene
      @black_background = {
        x: 0,
        y: 0,
        w: 720,
        h: 1280,
        path: :solid,
        r: 0,
        g: 0,
        b: 0,
        a: 255
      }
      $gtk.args.outputs.static_sprites << @black_background

      @game_complete_image = Zif::Sprite.new.tap do |i|
        i.x = 0
        i.y = 0
        i.h = 1280
        i.w = 720
        i.a = 0
        i.path = 'sprites/ui_game_complete.png'
      end
      $game.services[:action_service].register_actionable(@game_complete_image)
      $gtk.args.outputs.static_sprites << @game_complete_image

      $gtk.args.audio[:game_complete_music] ||= {
        input: "music/Lucas_HuskGame_118_DnB.wav",
        looping: true,
        gain: 0.5
      }
      @audio_fade = false
    end

    def perform_tick
      puts "GAME COMPLETE"

      handle_meta_input
      handle_input

      unless @started
        @game_complete_image.run_action(
          @game_complete_image.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3)
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