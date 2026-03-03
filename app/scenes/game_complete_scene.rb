module HuskGame
  class GameCompleteScene < Zif::Scene
    FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze

    def prepare_scene
      @next_scene = nil

      @black_background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid,
        r: 0, g: 0, b: 0, a: 255
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

      $gtk.args.audio[:game_complete_music] ||= {
        input: "music/Lucas_HuskGame_118_DnB.wav",
        looping: true,
        gain: 0.5
      }
      @audio_fade = false

      @data_blocks = $gtk.args.state.run.data_blocks
    end

    def setup_menu_button
      btn_size = 128
      btn_x = 720 - btn_size - 40
      btn_y = 40

      @menu_button = Zif::UI::TwoStageButton.new('GameCompleteMenuBtn').tap do |b|
        b.x = btn_x
        b.y = btn_y
        b.w = btn_size
        b.h = btn_size
        b.normal << Zif::Sprite.new('GameCompleteMenuBtnNormal').tap do |n|
          n.w = btn_size
          n.h = btn_size
          n.path = 'sprites/ui_button_large_up.png'
        end
        b.pressed << Zif::Sprite.new('GameCompleteMenuBtnPressed').tap do |p|
          p.w = btn_size
          p.h = btn_size
          p.path = 'sprites/ui_button_large_down.png'
        end
        b.on_mouse_up = lambda do |_sprite, _point|
          @fader.run_action(
            @fader.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3) {
              @next_scene = :menu_main
            }
          )
        end
        b.unpress
      end
      $game.services[:input_service].register_clickable @menu_button

      @menu_label = {
        x: btn_x + btn_size.half,
        y: btn_y + btn_size.half + 8,
        text: 'MENU',
        size: -2,
        font: FONT,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 255, g: 255, b: 255
      }
    end

    def perform_tick
      # puts "GAME COMPLETE"

      handle_meta_input
      handle_input

      @data_blocks = $gtk.args.state.run.data_blocks

      unless @started
        @game_complete_image.run_action(
          @game_complete_image.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3)
        )
        @started = true
      end

      $gtk.args.outputs.primitives << render_data_blocks
      $gtk.args.outputs.sprites << @menu_button
      $gtk.args.outputs.labels << @menu_label

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

    def render_data_blocks
      # puts "rendering data"
      output = []
      x_offset = 100
      y_offset = 40
      # puts "data_blocks: #{@data_blocks}"
      6.times do |i|
        data = @data_blocks[i]
        # puts "data: #{data}"
        data_corrupted = nil
        unless data.nil?
          data_corrupted = data[:corrupted]
        end
        case data_corrupted
        when true
          c = 180
        when false
          c = 250
        when nil
          c = 32
        end
        output << {
          x: x_offset,
          y: (40 * i) + y_offset,
          w: 96,
          h: 32,
          r: c - 16,
          g: c,
          b: c - 16,
          primitive_marker: :solid
        }
        output << {
          x: x_offset,
          y: (40 * i) + y_offset,
          w: 96,
          h: 32,
          r: 255,
          g: 255,
          b: 255,
          primitive_marker: :border
        }
      end
      return output
    end
  end
end