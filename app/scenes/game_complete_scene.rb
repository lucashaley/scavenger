module HuskGame
  class GameCompleteScene < Zif::Scene
    BUTTON_FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze
    TITLE_FONT = 'fonts/TAYRosemary.otf'.freeze

    def prepare_scene
      @next_scene = nil
      @revealed = false
      @exiting = false

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid,
        r: 58, g: 74, b: 58, a: 255
      }
      $gtk.args.outputs.static_sprites << @background

      @data_blocks = $gtk.args.state.run.data_blocks
      compute_stats
      setup_scene_labels
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
        f.a = 255
      end
      $game.services[:action_service].register_actionable(@fader)
      $gtk.args.outputs.static_sprites << @fader

      $gtk.args.audio[:game_complete_music] ||= {
        input: "music/Lucas_HuskGame_118_DnB.wav",
        looping: true,
        gain: 0.5
      }
      @audio_fade = false

    end

    def compute_stats
      blocks = @data_blocks || []
      collected = blocks.select { |b| b }
      @collected_count = collected.length
      @corrupted_count = collected.select { |b| b[:corrupted] }.length

      start_tick = $gtk.args.state.run.start_tick || 0
      end_tick = $gtk.args.state.run.end_tick || 0
      elapsed_ticks = end_tick - start_tick
      elapsed_ticks = elapsed_ticks.to_i
      total_seconds = elapsed_ticks.idiv(60)
      tenths = (elapsed_ticks % 60) * 10
      tenths = tenths.idiv(60)
      minutes = total_seconds.idiv(60)
      seconds = total_seconds % 60
      @elapsed_text = if minutes > 0
                        "Completed in #{minutes}m #{seconds}.#{tenths}s."
                      else
                        "Completed in #{seconds}.#{tenths} seconds."
                      end
    end

    def setup_scene_labels
      @scene_labels = [
        {
          x: 60, y: 920,
          text: 'RUN COMPLETE',
          size_enum: 38,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        },
        {
          x: 60, y: 720,
          text: 'YOU GOT IN,',
          size_enum: 8,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        },
        {
          x: 60, y: 640,
          text: 'YOU GOT OUT.',
          size_enum: 8,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        },
        {
          x: 60, y: 520,
          text: "#{@collected_count} datablocks collected.",
          size_enum: 4,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        },
        {
          x: 60, y: 470,
          text: "#{@corrupted_count} corrupted blocks.",
          size_enum: 4,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        },
        {
          x: 60, y: 420,
          text: @elapsed_text,
          size_enum: 4,
          font: TITLE_FONT,
          r: 176, g: 191, b: 170
        }
      ]
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
          return if @exiting
          @exiting = true
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
        size_enum: -1,
        font: BUTTON_FONT,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 255, g: 255, b: 255
      }
    end

    def perform_tick
      handle_meta_input
      handle_input

      unless @started
        @fader.run_action(
          @fader.new_action({a: 0}, duration: 0.5.seconds, easing: :smooth_step3) {
            @revealed = true
          }
        )
        @started = true
      end

      if @revealed && !@exiting
        @scene_labels.each { |l| $gtk.args.outputs.labels << l }
        $gtk.args.outputs.primitives << render_data_blocks
        $gtk.args.outputs.sprites << @menu_button
        $gtk.args.outputs.labels << @menu_label
      end

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
      output = []
      x_offset = 100
      y_offset = 40
      6.times do |i|
        data = @data_blocks[i]
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
