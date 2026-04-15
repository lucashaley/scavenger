module HuskGame
  class GameCompleteScene < HuskEngine::UtilityScene

    def prepare_scene
      super
      @revealed = false
      @exiting = false

      @background = {
        x: 0, y: 0, w: 720, h: 1280,
        path: :solid, a: 255
      }.merge(HuskGame::Constants::COLOR_DARK_GREEN)
      $gtk.args.outputs.static_sprites << @background

      @data_blocks = $gtk.args.state.run.data_blocks
      compute_stats
      setup_scene_labels
      setup_menu_button

      $gtk.args.audio[:game_complete_music] ||= {
        input: HuskGame::AssetPaths::Audio::MUSIC_118_DNB,
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

      @rooms_explored = $gtk.args.state.run.rooms_explored || 0
      @rooms_known = $gtk.args.state.run.rooms_known || 0
      @exploration_pct = @rooms_known > 0 ? (@rooms_explored * 100).idiv(@rooms_known) : 0

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
        blurred_label(60, 920, 'RUN COMPLETE', 38, 4),
        blurred_label(60, 720, 'YOU GOT IN,', 8, 2),
        blurred_label(60, 640, 'YOU GOT OUT.', 8, 2),
        {
          x: 60, y: 520,
          text: "#{@collected_count} datablocks collected.",
          size_enum: 4, font: TITLE_FONT
        }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN),
        {
          x: 60, y: 470,
          text: "#{@corrupted_count} corrupted blocks.",
          size_enum: 4, font: TITLE_FONT
        }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN),
        {
          x: 60, y: 420,
          text: @elapsed_text,
          size_enum: 4, font: TITLE_FONT
        }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN),
        {
          x: 60, y: 370,
          text: "#{@exploration_pct}% explored (#{@rooms_explored}/#{@rooms_known} rooms).",
          size_enum: 4, font: TITLE_FONT
        }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN)
      ].flatten
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
          return if @exiting
          @exiting = true
          @fader.run_action(
            @fader.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3) {
              @next_scene = :menu_main
            }
          )
        end
      end
      $game.services[:input_service].register_clickable @menu_button

      @menu_labels = blurred_label(680, btn_y + btn_h - 6, 'MENU', 32, 4, alignment_enum: 2)
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
        @menu_labels.each { |l| $gtk.args.outputs.labels << l }
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
