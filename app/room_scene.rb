class RoomScene < Zif::Scene
  include SpriteRegisters
  # include Zif::Traceable

  attr_accessor :ship, :husk

  FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze
  BUTTONS_CENTER = {x: 280, y: 260}.freeze

  def initialize
    @tile_dimensions = 64
    @map_dimensions = 10

    @ui_viewscreen_border = 40
    @ui_viewscreen_dimensions = 640
    @ui_viewscreen = {
      top: 1280 - 80,
      right: 720 - @ui_viewscreen_border,
      bottom: 1280 - 80 - @ui_viewscreen_dimensions,
      left: @ui_viewscreen_border
    }

    @ship
    @player_control = true

    @basic_tiles = []
    @door_tiles = []
    @pickups = []
    @buttons = []

    @label_style = {
      r: 0,
      g: 0,
      b: 255,
      size_px: 14
    }
    @background_style = {
      r: 0,
      g: 255,
      b: 0,
      a: 128,
      path: :solid
    }
  end

  def switch_rooms destination_door
    puts "\n\nRoomScene::switching rooms\n==============="
    puts "isn't this exciting"
    puts "#{destination_door}"
    @husk.switch_rooms destination_door.room, destination_door
    puts "\n\nRoomScene new room: #{@husk.current_room}"
  end

  def prepare_scene
    register_all_sprites

    # Create the ship
    @ship = Ship.new
    @ship.y = 1000
    @ship.x = 400
    $game.services.named(:action_service).register_actionable(@ship)

    # Create a husk
    @husk = Husk.new
    puts "husk: #{@husk}"

    # Handle audio
    # $gtk.args.audio[:bg_music] = { input: "sounds/ambient.ogg", looping: true }

    # Create the navigation buttons
    # Hopefully these work with mobile touches
    # FONT = 'sprites/kenney-uipack-space/Fonts/kenvector_future.ttf'.freeze
    # BUTTONS_CENTER = {x: 280, y: 260}.freeze
    @ui_button_north = Zif::UI::TwoStageButton.new.tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_large_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_large_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x - b.w.half
      b.y = BUTTONS_CENTER.y + b.h
      b.labels << Zif::UI::Label.new(
        'north',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.recenter_label
      b.unpress
    end
    @ui_button_south = Zif::UI::TwoStageButton.new.tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_large_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_large_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x - b.w.half
      b.y = BUTTONS_CENTER.y - b.h
      b.labels << Zif::UI::Label.new(
        'south',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.recenter_label
      b.unpress
    end
    @ui_button_east = Zif::UI::TwoStageButton.new.tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_large_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_large_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x + b.w.half
      b.y = BUTTONS_CENTER.y
      b.labels << Zif::UI::Label.new(
        'east',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.recenter_label
      b.unpress
    end
    @ui_button_west = Zif::UI::TwoStageButton.new.tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_large_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_large_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x - b.w.half - b.w
      b.y = BUTTONS_CENTER.y
      b.labels << Zif::UI::Label.new(
        'west',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.recenter_label
      b.unpress
    end
    rotate_ccw = lambda do |r|
      @ship.rotate_ccw
    end
    rotate_cw = lambda do |r|
      @ship.rotate_cw
    end
    @ui_button_ccw = Zif::UI::TwoStageButton.new('ui_button_ccw', &rotate_ccw).tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_rotate_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_rotate_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x - b.w.half - b.w
      b.y = BUTTONS_CENTER.y + b.h
      b.labels << Zif::UI::Label.new(
        'ccw',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.recenter_label
      b.unpress
    end
    @ui_button_cw = Zif::UI::TwoStageButton.new('ui_button_cw', &rotate_cw).tap do |b|
      b.normal << $services[:sprite_registry].construct(:ui_button_rotate_up)
      b.pressed << $services[:sprite_registry].construct(:ui_button_rotate_down)
      b.w = 128
      b.h = 128
      b.x = BUTTONS_CENTER.x + b.w.half
      b.y = BUTTONS_CENTER.y - b.h
      b.labels << Zif::UI::Label.new(
        'cw',
        size: -1,
        font: FONT,
        alignment: :center,
        vertical_alignment: :center,
        r: 255,
        g: 255,
        b: 255
      )
      b.flip_horizontally = true
      b.flip_vertically = true
      b.recenter_label
      b.unpress
    end

    # little array for buttons
    @buttons = [
      @ui_button_north,
      @ui_button_south,
      @ui_button_east,
      @ui_button_west,
      @ui_button_ccw,
      @ui_button_cw
    ]

    # Register all buttons as Clickables
    @buttons.each { |b| $game.services[:input_service].register_clickable b }

    @light = $services[:sprite_registry].construct(:light).tap do |s|
      s.x = 40
      s.y = 1280 - 700
      s.blend = Zif::Sprite::BLENDMODE[:multiply]
    end
    @ui = Zif::Sprite.new.tap do |s|
      s.w = 720
      s.h = 1280
      s.path = 'sprites/1bit_ui.png'
    end

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
      l.x = 40
      l.y = 1232
    end
    $gtk.args.outputs.static_labels << @ui_label_husk
  end

  def perform_tick
    # $gtk.add_caller_to_puts!
    handle_meta_input

    # Deads cleanup
    @husk.current_room.purge_deads
    @husk.calc_health

    # Do all the inputs, unless we've taken over player control
    handle_player_input if @ship.player_control

    handle_render

    # Is the game over?
    return :game_over if @husk.health <= 0
  end

  # It might be nice to have this, instead of the return value in the perform_tick method
  # def game_over
  #   puts "\n\nGAME OVER\n========="
  #   $game.scene = :game_over
  # end

  private

  def handle_meta_input
    # quit
    $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q

    # screenshot
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.outputs.screenshots << { x: 0, y: 0, w: 720, h: 1280, path: "sn-at-#{Kernel.tick_count}.png" }
    end

    # stop sound if space key is pressed
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.audio[:bg_music] = nil
      # OR
      $gtk.args.audio.delete :bg_music
    end
  end

  def handle_player_input
    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

    # Handle mouse clicks in directional buttons
    # We do this in the tick because button needs to repeat while held
    #
    if @ui_button_north.is_pressed
      # @ui_button_north.label.y = -0.1
      @ship.add_thrust_y (1.0)
    end
    if @ui_button_south.is_pressed
      @ship.add_thrust_y (-1.0)
    end
    if @ui_button_east.is_pressed
      @ship.add_thrust_x (1.0)
    end
    if @ui_button_west.is_pressed
      # @ui_button_west.label.y = -0.01
      @ship.add_thrust_x (-1.0)
    end

    # Handle the basic movement.
    # The left_right and up_down convenience methods are great
    @ship.add_thrust $gtk.args.inputs.left_right, $gtk.args.inputs.up_down

    # Effectors
    #
    # These are things that might change the player movement
    # mark('#standard_tick: Action service complete') if $game.services[:effect_service].run_all_effects
    $game.services[:effect_service].run_all_effects

    # Collisions
    #
    # So the way collisions are handled are by checking for any collisions along
    # the x axis first, and then along the y.
    #
    # For each axis, check all the different layers and make things collide.

    # Check for wall collisions along the x axis first
    @ship.calc_position_x

    # Check door collisions
    # collision_doors_x = $gtk.args.geometry.find_intersect_rect @ship, @room.doors
    collision_doors_x = $gtk.args.geometry.find_intersect_rect @ship, @husk.current_room.doors
    collision_doors_x.collide_x_with @ship if collision_doors_x

    # Check pickup collisions
    # collision_pickups_x = $gtk.args.geometry.find_intersect_rect @ship, @room.collidables
    collision_pickups_x = $gtk.args.geometry.find_intersect_rect @ship, @husk.current_room.collidables
    collision_pickups_x.collide_x_with @ship if collision_pickups_x

    # Check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_x @ui_viewscreen

    # and then along the y axis
    @ship.calc_position_y

    # Check door collisions
    collision_doors_y = $gtk.args.geometry.find_intersect_rect @ship, @husk.current_room.doors
    collision_doors_y.collide_y_with @ship if collision_doors_y

    # Check pickup collisions
    collision_pickups_y = $gtk.args.geometry.find_intersect_rect @ship, @husk.current_room.collidables
    collision_pickups_y.collide_y_with @ship if collision_pickups_y

    # check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_y @ui_viewscreen

    # Then we can apply drag
    @ship.apply_drag

    # Update light with ship coords
    @light.x = @ship.center_x - @light.w.half
    @light.y = @ship.center_y - @light.h.half
  end

  def handle_render
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
      @ui,
      @husk.deterioration_progress,
      @ship.data_progress,
      @buttons,
    # @camera.layers
    ]

    # This renders out the data boxes, maybe use sprites later on
    $gtk.args.outputs.primitives << @ship.render_data_blocks

    # Player info
    # $gtk.args.outputs.debug.watch pretty_format([@ship.energy, @ship.momentum, @ship.effect]), label_style: @label_style, background_style: @background_style
    # $gtk.args.outputs.debug.watch pretty_format(@map.layers[:ship].sprites), label_style: @label_style, background_style: @background_style
    $gtk.args.outputs.debug.watch [@husk, @ship.data], label_style: @label_style, background_style: @background_style
  end
end
