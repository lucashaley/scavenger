class EnvironmentScene < Zif::Scene
  # include Zif::Traceable

  def initialize
    @tile_dimensions = 64
    @map_dimensions = 10

    @ui_viewscreen_border = 32
    @ui_viewscreen_dimensions = 656
    @ui_viewscreen = {
      top: 1280 - @ui_viewscreen_border,
      right: 720 - @ui_viewscreen_border,
      bottom: 1280 - @ui_viewscreen_border - @ui_viewscreen_dimensions,
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

  def prepare_scene
    $services[:sprite_registry].register_basic_sprite(
      :ship_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :wall_16,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :wall2_08,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :doorh_128,
      width: 128,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :doorv_128,
      width: 64,
      height: 128
    )
    $services[:sprite_registry].register_basic_sprite(
      :pickup_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :mine_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :effector_64,
      width: 64,
      height: 64
    )

    # Create the ship
    @ship = Ship.new()
    @ship.y = 1000
    @ship.x = 400
    $game.services.named(:action_service).register_actionable(@ship)

    # Create a room
    @room = Room.new

    # Create the tiled grid
    @tilemap = Zif::Layers::LayerGroup.new(
      tile_width:     @tile_dimensions,
      tile_height:    @tile_dimensions,
      logical_width:  @map_dimensions,
      logical_height: @map_dimensions
    )
    @tilemap.new_tiled_layer(:tiles)
    @tilemap.layers[:tiles].width = 640
    @tilemap.layers[:tiles].height = 640

    # Starfield
    @starfield = {
      x: 0,
      y: 0,
      w: 640,
      h: 640,
      angle: rand(4) * 90,
      path: "sprites/starfield_01.png" }

    @tile_array = Array.new(@map_dimensions){Array.new(@map_dimensions)}
    @map_dimensions.times do |x|
      @map_dimensions.times do |y|
        # @tile_array[x][y] = { x: x * 64, y: y * 64, w: 64, h: 64, path: "sprites/walltop_64.png" }
        @tile_array[x][y] = {
          x: x * 64,
          y: y * 64,
          w: 64,
          h: 64,
          angle: rand(4) * 90,
          path: "sprites/1bit_floor_64_0#{rand(6)}.png" }
      end
    end

    # wall_tile = Zif::Sprite.new.tap do |s|
    #   s.x = 0
    #   s.y = 640 - 64
    #   s.w = 64
    #   s.h = 64
    #   s.path = 'sprites/walltop_64.png'
    # end
    @tiles_target = { x: 40,
                      y: 600,
                      w: 640,
                      h: 640,
                      path: :tiles,
                      source_x: 0,
                      source_y: 0,
                      source_w: 640,
                      source_h: 640
                    }
    # $gtk.args.outputs[:tiles].sprites << { x: 0, y: 0, w: 64, h: 64, path: "sprites/square/blue.png" }
    # $gtk.args.outputs[:tiles].sprites << wall_tile

    # @map_dimensions.times do |x|
    #   @map_dimensions.times do |y|
    #     $gtk.args.outputs[:tiles].sprites << { x: x * 64, y: y * 64, w: 64, h: 64, path: "sprites/square/blue.png" }
    #   end
    # end

    # Create pickups and hazards
    boost_thrust = BoostThrust.new(
      $services[:sprite_registry].construct(:pickup_64),
      360 + 10,
      800,
      0.8,
      1
    )
    @pickups << boost_thrust
    mine = Mine.new(
      $services[:sprite_registry].construct(:mine_64),
      360,
      900
    )
    @pickups << mine

    repulsor = Repulsor.new(
      $services[:sprite_registry].construct(:effector_64),
      600,
      900
    )
    repulsor.effect_target = @ship
    $game.services[:effect_service].register_effectable repulsor
    @pickups << repulsor

    # attractor = Attractor.new(
    #   $services[:sprite_registry].construct(:effector_64),
    #   100,
    #   700
    # )
    # attractor.effect_target = @ship
    # $game.services[:effect_service].register_effectable attractor
    # @pickups << attractor

    # Create doors
    door = Door.new(
      $services[:sprite_registry].construct(:doorh_128),
      360 - 64,
      1200
    )
    @door_tiles << door
    door_left = Door.new(
      $services[:sprite_registry].construct(:doorv_128),
      32,
      900,
      1.5,
      Faceable::FACING::east
    )
    puts door_left
    @door_tiles << door_left

    # Handle audio
    # $gtk.args.audio[:bg_music] = { input: "sounds/ambient.ogg", looping: true }

    # Create the navigation buttons
    # Hopefully these work with mobile touches
    @button_north = ExampleApp::TallButton.new(:static_button, 160, :nine, 'N', 2)
    @button_north.x = 360 - 80
    @button_north.y = 128 + 192 + @ui_viewscreen_border
    @button_south = ExampleApp::TallButton.new(:static_button, 160, :nine, 'S', 2)
    @button_south.x = 360 - 80
    @button_south.y = 128
    @button_east = ExampleApp::TallButton.new(:static_button, 160, :nine, 'E', 2)
    @button_east.x = 360 + 80 + @ui_viewscreen_border
    @button_east.y = 128 + 80
    @button_west = ExampleApp::TallButton.new(:static_button, 160, :nine, 'W', 2)
    @button_west.x = 360 - 80 - @ui_viewscreen_border - 160
    @button_west.y = 128 + 80
    @button_ccw = ExampleApp::TallButton.new(:static_button, 160, :nine, 'CCW', 2) do |point|
      # is_pressed only fires once, so we can't use it for button helds
      # But it works fine for quantized rotation
      if @button_ccw.is_pressed
        # This is for stepped rotation, to fix later with animation states
        @ship.rotate_ccw
      end
    end
    @button_ccw.x = 360 - 80 - @ui_viewscreen_border - 160
    @button_ccw.y = 100 + 96 + 192 + @ui_viewscreen_border
    @button_cw = ExampleApp::TallButton.new(:static_button, 160, :nine, 'CW', 2) do |point|
      if @button_cw.is_pressed
        # This is for stepped rotation, to fix later with animation states
        @ship.rotate_cw
      end
    end
    @button_cw.x = 360 + 80 + @ui_viewscreen_border
    @button_cw.y = 128 - 192 + @ui_viewscreen_border

    # little array for buttons
    @buttons = [
      @button_north,
      @button_south,
      @button_east,
      @button_west,
      @button_ccw,
      @button_cw
    ]

    # Register all buttons as Clickables
    @buttons.each { |b| $game.services[:input_service].register_clickable b }

    @backdrop = Zif::Sprite.new.tap do |s|
      s.w = 720
      s.h = 720
      s.y = 1280 - 720
      s.path = 'sprites/backdrop_01.png'
    end
    @ui = Zif::Sprite.new.tap do |s|
      s.w = 720
      s.h = 1280
      s.path = 'sprites/1bit_ui.png'
    end

    # We're now putting this in tick, so we can use a render target
    # Render everything without layers
    # $gtk.args.outputs.static_sprites << [
    #   @backdrop,
    #   @tilemap.layer_containing_sprites,
    #   @pickups,
    #   @ship,
    #   @door_tiles,
    #   @ui,
    #   @buttons
    # ]
  end

  def perform_tick
    # $gtk.add_caller_to_puts!
    $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q

    # $gtk.args.outputs[:tiles].sprites << { x: 0, y: 0, w: 640, h: 640, path: "sprites/square/blue.png" }
    # @map_dimensions.times do |x|
    #   @map_dimensions.times do |y|
    #     $gtk.args.outputs[:tiles].sprites << { x: x * 64, y: y * 64, w: 64, h: 64, path: "sprites/walltop_64.png" }
    #   end
    # end
    # $gtk.args.outputs[:tiles].sprites << @starfield
    $gtk.args.outputs[:tiles].transient! # This apparently speeds up render
    @map_dimensions.times do |x|
      @map_dimensions.times do |y|
        $gtk.args.outputs[:tiles].sprites << @tile_array[x][y]
      end
    end

    # Deads cleanup
    @pickups.reject! { |p| p.is_dead }

    # stop sound if space key is pressed
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.audio[:bg_music] = nil
      # OR
      $gtk.args.audio.delete :bg_music
    end

    return if !@player_control
    return if !@ship.player_control

    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

    # Handle mouse clicks in directional buttons
    # We do this in the tick because button needs to repeat while held
    if @button_north.is_pressed
      @ship.add_thrust_y 1.0
    end
    if @button_south.is_pressed
      @ship.add_thrust_y -1.0
    end
    if @button_east.is_pressed
      @ship.add_thrust_x 1.0
    end
    if @button_west.is_pressed
      @ship.add_thrust_x -1.0
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
    collision_doors_x = $gtk.args.geometry.find_intersect_rect @ship, @door_tiles
    collision_doors_x.collide_x_with @ship if collision_doors_x

    # Check pickup collisions
    collision_pickups_x = $gtk.args.geometry.find_intersect_rect @ship, @pickups.reject{ |p| p.is_dead }
    collision_pickups_x.collide_x_with @ship if collision_pickups_x

    # Check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_x @ui_viewscreen

    # and then along the y axis
    @ship.calc_positon_y

    # Check door collisions
    collision_doors_y = $gtk.args.geometry.find_intersect_rect @ship, @door_tiles
    collision_doors_y.collide_y_with @ship if collision_doors_y

    # Check pickup collisions
    collision_pickups_y = $gtk.args.geometry.find_intersect_rect @ship, @pickups.reject{ |p| p.is_dead }
    collision_pickups_y.collide_y_with @ship if collision_pickups_y

    # check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_y @ui_viewscreen

    # Then we can apply drag
    @ship.apply_drag


    # Render everything
    $gtk.args.outputs.sprites << [
      # @backdrop,
      @tiles_target,
      @pickups,
      @ship,
      @door_tiles,
      @ui,
      @buttons
    ]

    # Player info
    # $gtk.args.outputs.debug.watch pretty_format([@ship.energy, @ship.momentum, @ship.effect]), label_style: @label_style, background_style: @background_style
    # $gtk.args.outputs.debug.watch pretty_format(@map.layers[:ship].sprites), label_style: @label_style, background_style: @background_style
    # $gtk.args.outputs.debug.watch pretty_format(@tile_array), label_style: @label_style, background_style: @background_style
  end
end
