# frozen_string_literal: true
module HuskGame
  class MenuMainScene < HuskEngine::UtilityScene

    def prepare_scene
      super
      @name = "MainMenu"

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid, a: 255
      }.merge(HuskGame::Constants::COLOR_DARK_GREEN)
      $gtk.args.outputs.static_sprites << @background

      setup_scene_labels
      setup_play_button
      setup_about_button

      $gtk.args.audio[:splash_music] ||= {
        input: "music/Lucas_HuskGame_intro_DnB.wav",
        looping: true,
        gain: 0.4
      }
    end

    def unload_scene
      super
      $gtk.args.audio.clear
    end

    private

    def setup_scene_labels
      @scene_labels = [
        blurred_label(360, 1100, 'HUSK', 100, 4, alignment_enum: 1),
      ].flatten
    end

    def setup_play_button
      btn_w = 500
      btn_h = 140
      btn_x = 720 - btn_w - 40
      btn_y = 340

      @play_button = Zif::Sprite.new.tap do |s|
        s.x = btn_x
        s.y = btn_y
        s.w = btn_w
        s.h = btn_h
        s.path = :solid
        s.a = 0
        s.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :husk_select
        end
      end
      $game.services[:input_service].register_clickable @play_button
      @render_layers << @play_button

      pulsing_blurred_label(680, btn_y + btn_h - 10, 'PLAY', 48, 1, 3, alignment_enum: 2)
    end

    def setup_about_button
      btn_w = 500
      btn_h = 120
      btn_x = 720 - btn_w - 40
      btn_y = 180

      @about_button = Zif::Sprite.new.tap do |s|
        s.x = btn_x
        s.y = btn_y
        s.w = btn_w
        s.h = btn_h
        s.path = :solid
        s.a = 0
        s.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :menu_about
        end
      end
      $game.services[:input_service].register_clickable @about_button
      @render_layers << @about_button

      @scene_labels += blurred_label(680, btn_y + btn_h - 6, 'ABOUT', 32, 4, alignment_enum: 2)
    end
  end
end
