# frozen_string_literal: true
module HuskGame
  class AboutScene < HuskEngine::UtilityScene
    BUTTON_FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze

    def prepare_scene
      super
      @name = "About"

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid,
        r: 58, g: 74, b: 58, a: 255
      }
      $gtk.args.outputs.static_sprites << @background

      setup_scene_labels
      setup_back_button

      $gtk.args.audio[:splash_music] ||= {
        input: "music/Lucas_HuskGame_intro_DnB.wav",
        looping: true,
        gain: 0.4
      }
    end

    private

    def setup_scene_labels
      @scene_labels = [
        blurred_label(60, 1100, 'HUSK', 42, 4),
        blurred_label(60, 920, 'CREDITS', 14, 3),
        credit_label(60, 840, 'Game Design & Code'),
        credit_label(100, 800, 'Lucas Haley'),
        credit_label(60, 720, 'Music & Audio'),
        credit_label(100, 680, 'Atomicon'),
        credit_label(60, 320, 'Built with'),
        credit_label(100, 280, 'DragonRuby Game Toolkit'),
        credit_label(100, 240, 'Zif Framework (Dan Healy)'),
      ].flatten
    end

    def credit_label(x, y, text)
      {
        x: x, y: y,
        text: text,
        size_enum: 5,
        font: TITLE_FONT,
        r: 176, g: 191, b: 170
      }
    end

    def setup_back_button
      btn_size = 128
      btn_x = 720 - btn_size - 40
      btn_y = 40

      @back_button = Zif::UI::TwoStageButton.new('AboutBackBtn').tap do |b|
        b.x = btn_x
        b.y = btn_y
        b.w = btn_size
        b.h = btn_size
        b.normal << Zif::Sprite.new('AboutBackBtnNormal').tap do |n|
          n.w = btn_size
          n.h = btn_size
          n.path = 'sprites/ui_button_large_up.png'
        end
        b.pressed << Zif::Sprite.new('AboutBackBtnPressed').tap do |p|
          p.w = btn_size
          p.h = btn_size
          p.path = 'sprites/ui_button_large_down.png'
        end
        b.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :menu_main
        end
        b.unpress
      end
      $game.services[:input_service].register_clickable @back_button
      @render_layers << @back_button

      @scene_labels << {
        x: btn_x + btn_size.half,
        y: btn_y + btn_size.half + 8,
        text: 'BACK',
        size_enum: -1,
        font: BUTTON_FONT,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 255, g: 255, b: 255
      }
    end
  end
end
