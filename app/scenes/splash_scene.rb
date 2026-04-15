module HuskGame
  class SplashScene < HuskEngine::UtilityScene
    FADE_DURATION = 90.frames  # 1.5s

    def prepare_scene
      super
      @current_scene_tick = 0
      @audio_fade = false

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid, a: 255
      }.merge(HuskGame::Constants::COLOR_DARK_GREEN)

      setup_title_render_target

      $gtk.args.audio[:splash_music] ||= {
        input: HuskGame::AssetPaths::Audio::MUSIC_INTRO_DNB,
        looping: true,
        gain: 0
      }
    end

    def setup_title_render_target
      @title_rt = Zif::RenderTarget.new(
        :splash_title,
        bg_color: [0, 0, 0, 0],
        width: 720,
        height: 1280
      )
      @title_rt.labels = blurred_label(360, 780, 'H.U.S.C.', 120, 10, alignment_enum: 1)
      @title_rt.redraw

      @title_sprite = @title_rt.containing_sprite
      @title_sprite.a = 255
    end

    def enter_scene
      @ready = true
      @fader.run_action(
        @fader.new_action({a: 0}, duration: FADE_DURATION, easing: :smooth_step3)
      )
      @started = true
    end

    def exit_scene(up_next)
      @fader.run_action(
        @fader.new_action({a: 255}, duration: FADE_DURATION, easing: :smooth_step3) { @next_scene = up_next }
      )
    end

    def perform_tick
      handle_audio_fade

      if @current_scene_tick == 300 || $gtk.args.inputs.mouse.click
        trigger_exit
      end

      @current_scene_tick += 1

      # Background → title → fader (fader added last via super)
      $gtk.args.outputs.sprites << @background
      $gtk.args.outputs.sprites << @title_sprite

      super
    end

    def trigger_exit
      return if @audio_fade
      @audio_fade = true
      exit_scene :menu_main
    end

    def handle_audio_fade
      music = $gtk.args.audio[:splash_music]
      return unless music

      if @audio_fade
        if music.gain > 0.0
          music.gain -= 0.01667
          music.gain = 0.0 if music.gain < 0.0
        end
      else
        if music.gain < 1.0
          music.gain += 0.3
          music.gain = 1.0 if music.gain > 1.0
        end
      end
    end

    def unload_scene
      super
      $gtk.args.audio[:splash_music] = nil
    end
  end
end
