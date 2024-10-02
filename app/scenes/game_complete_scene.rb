module HuskGame
  class GameCompleteScene < Zif::Scene
    def prepare_scene
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

      $gtk.args.audio[:game_complete_music] ||= {
        input: "music/Lucas_HuskGame_118_DnB.wav",
        looping: true,
        gain: 0.5
      }
      @audio_fade = false

      @data_blocks = $gtk.args.state.run.data_blocks
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

      # $gtk.args.outputs.debug.watch [$gtk.args.state.run.data_blocks], label_style: $LABEL_STYLE, background_style: $BACKGROUND_STYLE
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