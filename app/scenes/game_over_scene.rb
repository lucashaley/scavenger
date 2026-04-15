module HuskGame
  class GameOverScene < Zif::Scene
    include Zif::Traceable

    FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze

    TITLE_FONT = 'fonts/TAYRosemary.otf'.freeze

    def prepare_scene
      @tracer_service_name = :tracer
      @current_scene_tick = 0
      @started = false
      @next_scene = nil

      compute_stats

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

      setup_menu_button

      @fader = Zif::Sprite.new.tap do |f|
        f.x = 0
        f.y = 0
        f.w = 720
        f.h = 1280
        f.path = :solid
        f.r = 0
        f.g = 0
        f.b = 0
        f.a = 0
      end
      $game.services[:action_service].register_actionable(@fader)
      $gtk.args.outputs.static_sprites << @fader

      $gtk.args.audio[:game_over_music] ||= {
        input: HuskGame::AssetPaths::Audio::MUSIC_INTRO_DNB,
        looping: true,
        gain: 0.5
      }
      @audio_fade = false
    end

    def setup_menu_button
      btn_w = 500
      btn_h = 120
      btn_x = 720 - btn_w - 40
      btn_y = 40

      @menu_button = Zif::Sprite.new.tap do |s|
        s.x = btn_x
        s.y = btn_y
        s.w = btn_w
        s.h = btn_h
        s.path = :solid
        s.a = 0
        s.on_mouse_up = lambda do |_sprite, _point|
          @fader.run_action(
            @fader.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3) {
              @next_scene = :menu_main
            }
          )
        end
      end
      $game.services[:input_service].register_clickable @menu_button

      @menu_labels = blurred_label(720 - 40, btn_y + btn_h - 6, 'MENU', 32, 4, alignment_enum: 2)
    end

    def perform_tick
      handle_meta_input
      handle_input

      unless @started
        @game_over_image.run_action(
          @game_over_image.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3)
        )
        @started = true
      end

      $gtk.args.outputs.sprites << @menu_button
      @menu_labels.each { |l| $gtk.args.outputs.labels << l }
      $gtk.args.outputs.labels << @stats_label

      return @next_scene
    end

    def unload_scene
      $gtk.args.audio.clear
      $gtk.args.outputs.static_sprites.clear
      $game.services[:input_service].reset
    end

    def handle_meta_input
      $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q
    end

    def handle_input
    end

    def blurred_label(x, y, text, size, offset, alignment_enum: 0)
      base = { text: text, size_enum: size, font: TITLE_FONT, alignment_enum: alignment_enum }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN)
      shadows = [
        { x: x,          y: y + offset },
        { x: x,          y: y - offset },
        { x: x - offset, y: y },
        { x: x + offset, y: y }
      ].map { |pos| base.merge(pos).merge(a: 76) }
      shadows << base.merge(x: x, y: y, a: 255)
    end

    def compute_stats
      rooms_visited = $gtk.args.state.run.rooms_visited || 0
      rooms_discovered = $gtk.args.state.run.rooms_discovered || 0
      pct = rooms_discovered > 0 ? (rooms_visited * 100).idiv(rooms_discovered) : 0

      @stats_label = {
        x: 60, y: 200,
        text: "#{pct}% mapped (#{rooms_visited}/#{rooms_discovered} rooms).",
        size_enum: 4, font: TITLE_FONT
      }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN)
    end
  end
end
