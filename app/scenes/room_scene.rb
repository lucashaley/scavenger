module HuskGame
  class RoomScene < Zif::Scene
    include SpriteRegisters
    include Zif::Traceable
    include HuskEngine::Soundable
    include HuskGame::FragmentUi
    include HuskGame::FragmentInput
    include HuskGame::FragmentShip

    attr_accessor :ship, :husk
    attr_accessor :player_controls

    FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze
    BUTTONS_CENTER = {x: 280, y: 260}.freeze

    def initialize
      puts "\n\nROOM_SCENE: INIT\n\n"
      super
      initialize_dimensions
      initialize_collections
      initialize_game_state
      initialize_styles
      initialize_audio_settings
      initialize_gameplay_state
    end

    private

    def initialize_dimensions
      @tile_dimensions = 64
      @map_dimensions = 10
      @ui_viewscreen_border = HuskGame::Constants::VIEWSCREEN_BORDER
      @ui_viewscreen_dimensions = HuskGame::Constants::VIEWSCREEN_SIZE
      @ui_viewscreen = HuskGame::Constants::VIEWSCREEN
    end

    def initialize_collections
      @basic_tiles = []
      @door_tiles = []
      @pickups = []
      @buttons = []
    end

    def initialize_game_state
      @ship = nil
      @player_control = true
      @emp_power = 0
      @shutdown = nil
      @tracer_service_name = :tracer
    end

    def initialize_styles
      @label_style = HuskGame::Constants::LABEL_STYLE
      @background_style = HuskGame::Constants::BACKGROUND_STYLE
    end

    def initialize_audio_settings
      @bg_music_state = :intro
      @bg_music_volume = 0.3
      @emp_sound = HuskGame::AssetPaths::Audio::EMP_BLAST
    end

    def initialize_gameplay_state
      state = $gtk.args.state
      state.gameplay = {
        max_emp_power: 4.seconds,
        button_thrust: 0.8
      }
      state.agents = []
      state.hazards = []
      state.pickups = []
    end

    public

    def switch_rooms destination_door
      fade_out(0.2.seconds) do
        @husk.switch_rooms destination_door.room, destination_door
      end
    end

    def fade_out(duration, &block)
      duration ||= 0.5.seconds
      @fader.run_action(
        @fader.new_action({a: 255}, duration: duration, easing: :smooth_step3) {
          block.call unless block.nil?
        }
      )
    end

    def fade_in(duration, &block)
      duration ||= 0.5.seconds
      @fader.run_action(
        @fader.new_action({a: 0}, duration: duration, easing: :smooth_step3) {
          block.call unless block.nil?
        }
      )
    end

    def prepare_scene
      puts "\n\nROOM_SCENE: PREPARE_SCENE\n\n"
      $gtk.args.state.run.start_tick = Kernel.tick_count
      register_all_sprites
      setup_fader
      setup_ship
      setup_husk
      setup_light
      setup_ui_sprites
      setup_ui_health_indicators
      setup_ui_labels
      setup_background_music
    end

    private

    def setup_fader
      @fader = Zif::Sprite.new.tap do |f|
        f.x = 0
        f.y = 0
        f.w = HuskGame::Constants::SCREEN_WIDTH
        f.h = HuskGame::Constants::SCREEN_HEIGHT
        f.path = :solid
        f.r = 0
        f.g = 0
        f.b = 0
        f.a = 0
      end
      $game.services[:action_service].register_actionable(@fader)
      $gtk.args.outputs.static_sprites << @fader
    end

    def setup_ship
      # Create the ship before the husk because ship scale gets set in switch_room
      @ship = Ship.new
      @ship.x = HuskGame::Constants::VIEWSCREEN_OFFSET_X + (HuskGame::Constants::VIEWSCREEN_SIZE - 64).half
      @ship.y = HuskGame::Constants::SCREEN_HEIGHT - 48 - 64 - HuskGame::Constants::VIEWSCREEN_SIZE.half
      $game.services.named(:action_service).register_actionable(@ship)
      $gtk.args.state.ship = @ship
    end

    def setup_husk
      @husk = Husk.new
      puts "husk: #{@husk}"
    end

    def setup_light
      @light = $services[:sprite_registry].construct(:light).tap do |s|
        s.x = HuskGame::Constants::VIEWSCREEN_OFFSET_X
        s.y = HuskGame::Constants::SCREEN_HEIGHT - 700
        s.blendmode_enum = Zif::Sprite::BLENDMODE[:multiply]
      end
      $game.services[:action_service].register_actionable(@light)
    end

    def setup_ui_sprites
      @ui = Zif::Sprite.new.tap do |s|
        s.w = HuskGame::Constants::SCREEN_WIDTH
        s.h = HuskGame::Constants::SCREEN_HEIGHT
        s.path = HuskGame::AssetPaths::Sprites::UI_MAIN
      end
    end

    def setup_ui_health_indicators
      health_size = 124
      @ui_ship_health = create_health_sprite('sprites/ui_ship_health.png', health_size)
      @ui_ship_health_west = create_health_hash('sprites/ui_ship_health_west.png', health_size)
      @ui_ship_health_east = create_health_sprite('sprites/ui_ship_health_east.png', health_size)
      @ui_ship_health_north = create_health_sprite('sprites/ui_ship_health_north.png', health_size)
      @ui_ship_health_south = create_health_sprite('sprites/ui_ship_health_south.png', health_size)
    end

    def create_health_sprite(path, size)
      Zif::Sprite.new.tap do |s|
        s.w = size
        s.h = size
        s.path = path
        s.blendmode_enum = :add
      end
    end

    def create_health_hash(path, size)
      {
        w: size,
        h: size,
        path: path,
        blendmode_enum: 2,
        a: 255
      }
    end

    def blink_alpha(health)
      return (health * 255).to_i if health >= 1.0

      speed = (1.0 - health) * 0.3
      wave = (Math.sin(Kernel.tick_count * speed) + 1.0) / 2.0
      (health * 255 * wave).to_i
    end

    def setup_ui_labels
      @ui_label_husk = Zif::UI::Label.new(
        'husk integrity:',
        size: -1,
        font: FONT,
        alignment: :left,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      ).tap do |l|
        l.x = HuskGame::Constants::VIEWSCREEN_OFFSET_X
        l.y = 1232
      end
      $gtk.args.outputs.static_labels << @ui_label_husk
    end

    def setup_background_music
      $gtk.args.state.bgmusic.playing ||= true
      $gtk.args.audio[:bg_music] ||= {
        input: HuskGame::AssetPaths::Audio::MUSIC_INTRO,
        looping: false,
        gain: @bg_music_volume
      }
    end

    public

    def unload_scene
      $gtk.args.audio.clear
      $gtk.args.outputs.static_sprites.clear
      $gtk.args.outputs.static_labels.clear
      $gtk.args.outputs[:viewport_mask].clear
      $gtk.args.outputs[:viewport].clear
    end

    def perform_tick
      # $gtk.add_caller_to_puts!
      # mark_and_print ("perform_tick")
      handle_bgmusic
      handle_meta_input

      handle_ticks

      # Deads cleanup
      @husk.current_room.purge_deads
      @husk.calc_health

      # Do all the inputs, unless we've taken over player control
      handle_player_input if @ship.player_control

      handle_light

      handle_ui

      handle_render

      # Shader stuff
      # $gtk.args.outputs.shader_path ||= "shaders/crt.glsl"
      # $gtk.args.outputs.shader_tex1 = :viewport
      # $gtk.args.outputs.shader_tex2 = :viewport_mask


      handle_shutdown if @shutdown.nil? && (@husk.breach.locked || @husk.health <= 0)
      return :game_complete if @husk.breach.locked && @shutdown == :done
      return :game_over if @husk.health <= 0 && @shutdown == :done
    end

    private

    # get our fade out going
    def handle_shutdown
      @shutdown = :started
      @player_control = false

      $gtk.args.state.run.data_blocks = @ship.data_blocks
      $gtk.args.state.run.end_tick = Kernel.tick_count

      @fader.run_action(
        @fader.new_action({a: 255}, duration: 0.5.seconds, easing: :smooth_step3) {
          @shutdown = :done
        }
      )
    end

    # This changes the bg music based upon the husk health -- the worse the health, the faster the music.
    def handle_bgmusic
      # mark_and_print ("handle_bgmusic")
      if $gtk.args.audio[:bg_music].nil? && $gtk.args.state.bgmusic.playing
        @bg_music_state = case @husk.health
                          when 0.5..1.0
                            :theme_108
                          when 0.25..0.5
                            :theme_118
                          when 0.0..0.25
                            :theme_128
                          end
        input = case @bg_music_state
                when :intro
                  "108"
                when :theme_108
                  ["108", "108_DnB"].sample
                when :theme_118
                  ["118", "118_DnB"].sample
                when :theme_128
                  ["128", "128_DnB"].sample
                end
        $gtk.args.audio[:bg_music] = {
          input: "music/Lucas_HuskGame_#{input}.wav",
          looping: false,
          gain: @bg_music_volume
        }
      end

      # Ducking music for voiceovers
      unless $gtk.args.audio[:bg_music].nil?
        if $gtk.args.audio[:voiceover]
          $gtk.args.audio[:bg_music].gain -= 0.1
        else
          $gtk.args.audio[:bg_music].gain += 0.1
        end
        $gtk.args.audio[:bg_music].gain = $gtk.args.audio[:bg_music].gain.clamp(0.1, @bg_music_volume)
      end
    end

    def handle_emp
      return if @ship.emp_count <= 0
      # mark_and_print "handle_emp: #{@emp_power}"
      @ui_button_emp.unpress unless @ui_button_emp.nil?

      play_once @emp_sound unless @emp_sound.nil?

      # turn the light off for a bit
      @light.run_action(
        Zif::Actions::Sequence.new(
          [
            @light.new_action(
              {a: 255 - @emp_power.clamp(0, 255)},
              duration: 7,
              easing: :smooth_start
            ) {  },
            @light.new_action(
              {a: 255},
              duration: 14,
              easing: :smooth_stop
            ) {  }
          ],
          repeat: :once
        )
      )

      # handle the effects
      $game.services[:emp_service].run_all_emps(@emp_power)

      # reset the power
      @emp_power = 0
      @ship.emp_count -= 1
    end

    def handle_light
      # mark_and_print("handle_light")
      # Update light with ship coords
      @light.x = @ship.center_x - @light.w.half
      @light.y = @ship.center_y - @light.h.half
    end

    def handle_ticks
      $game.services[:tick_service].run_all_ticks
    end

    def handle_render
      # mark_and_print("handle_render")

      # Outputs for shaders
      # $gtk.args.outputs[:viewport].transient!
      # $gtk.args.outputs[:viewport].w = 720
      # $gtk.args.outputs[:viewport].h = 1280
      # $gtk.args.outputs[:viewport].sprites << [
      #   @husk.current_room.tiles_target.containing_sprite.assign({ x: 40, y: 560 }),
      #   @husk.current_room.renders_under_player,
      #   @ship,
      #   @light,
      #   @husk.current_room.renders_over_player,
      #   # @room.doors,
      #   @husk.current_room.doors,
      #   @light,
      # ]
      #
      # $gtk.args.outputs[:viewport_mask].w = 720
      # $gtk.args.outputs[:viewport_mask].h = 1280
      # $gtk.args.outputs[:viewport_mask].sprites << { x: 0, y: 0, w: 720, h: 1280, path: "sprites/viewport_mask.png" }

      # puts [
      #   @ship.health_west * 128,
      #   @ship.health_east * 128,
      #   @ship.health_north * 128,
      #   @ship.health_south * 128
      #      ]

      # @ui_ship_health_west.assign({a: @ship.health_west * 255})

      @ui_ship_health_west.a = blink_alpha(@ship.health_west)
      @ui_ship_health_east.a = blink_alpha(@ship.health_east)
      @ui_ship_health_north.a = blink_alpha(@ship.health_north)
      @ui_ship_health_south.a = blink_alpha(@ship.health_south)

      # puts "west: #{@ui_ship_health_west.a}"

      $gtk.args.outputs.sprites.clear
      $gtk.args.outputs.sprites << [
        @husk.current_room.tiles_target.containing_sprite.assign({ x: 40, y: 560 }),
        @husk.current_room.renders_under_player,
        @ship,
        @light,
        @husk.current_room.renders_over_player,
        # @room.doors,
        @husk.current_room.doors,
        @light,
        @husk.current_room.overlays,
        @light,
        [
          @ui,
          @ui_ship_health,
          @ui_ship_health_west,
          @ui_ship_health_east,
          @ui_ship_health_north,
          @ui_ship_health_south
        ],
        @husk.deterioration_progress,
        @ship.data_progress,
        # @buttons,
        # @ui_cluster.render
        # @player_controls.containing_sprite.assign({x: 40, y: 120})
      # @camera.layers
      ].flatten

      # This renders out the data boxes, maybe use sprites later on
      $gtk.args.outputs.primitives << @ship.render_data_blocks

      # # debug for button centers
      # $gtk.args.outputs.debug << $gtk.args.state.ui.buttons.map do |b|
      #   {
      #     x: b.click_center.x,
      #     y: b.click_center.y,
      #     w: 10,
      #     h: 10,
      #     r: 255,
      #     g: 10,
      #     b: 10,
      #     a: 255,
      #     primitive_marker: :solid
      #   }
      # end

      $gtk.args.outputs.sprites << $gtk.args.state.ui.buttons
      $gtk.args.outputs.sprites << $gtk.args.state.ui.statuses.values

      # Player info
      # $gtk.args.outputs.debug.watch pretty_format([@ship.energy, @ship.momentum, @ship.effect]), label_style: @label_style, background_style: @background_style
      # $gtk.args.outputs.debug.watch pretty_format(@map.layers[:ship].sprites), label_style: @label_style, background_style: @background_style
      $gtk.args.outputs.debug.watch [@ship.emp_count, @husk.health, @husk.current_room.scale], label_style: $LABEL_STYLE, background_style: $BACKGROUND_STYLE
    end
  end
end