# frozen_string_literal: true
module HuskGame
  class HuskSelectScene < HuskEngine::UtilityScene

    def prepare_scene
      super
      @name = "HuskSelect"

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid, a: 255
      }.merge(HuskGame::Constants::COLOR_DARK_GREEN)
      $gtk.args.outputs.static_sprites << @background

      setup_scene_labels
      setup_husk_buttons
    end

    def unload_scene
      super
      $gtk.args.audio.clear
    end

    private

    def setup_scene_labels
      @scene_labels = [
        blurred_label(360, 1100, 'SELECT HUSK', 48, 4, alignment_enum: 1),
      ].flatten
    end

    def setup_husk_buttons
      btn_w = 560
      btn_h = 120
      btn_x = (720 - btn_w).half
      start_y = 800

      HuskGame::Constants::HUSK_TYPES.each_with_index do |husk_type, i|
        btn_y = start_y - (i * (btn_h + 20))
        chaos = husk_type[:chaos]

        button = Zif::Sprite.new.tap do |s|
          s.x = btn_x
          s.y = btn_y
          s.w = btn_w
          s.h = btn_h
          s.path = :solid
          s.a = 0
          s.on_mouse_up = lambda do |_sprite, _point|
            return unless @ready
            select_husk(chaos)
          end
        end
        $game.services[:input_service].register_clickable button
        @render_layers << button

        # Husk name label
        @scene_labels += blurred_label(
          btn_x + 20, btn_y + btn_h - 16,
          husk_type[:name], 12, 2
        )

        # Description label
        @scene_labels << {
          x: btn_x + 20, y: btn_y + 36,
          text: husk_type[:description],
          size_enum: 0, font: TITLE_FONT
        }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN).merge(a: 180)

        # Chaos indicator blocks
        4.times do |c|
          filled = c < husk_type[:chaos]
          block_x = btn_x + btn_w - 40 - (4 - c) * 28
          block_y = btn_y + btn_h.half - 8

          @render_layers << {
            x: block_x, y: block_y, w: 20, h: 16,
            path: :solid,
            r: 198, g: 207, b: 186, a: filled ? 255 : 40
          }
        end
      end
    end

    def select_husk(chaos)
      $gtk.args.state.husk_config ||= {}
      $gtk.args.state.husk_config.initial_chaos = chaos
      exit_scene :room
    end
  end
end
