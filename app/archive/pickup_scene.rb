class ClassScene < Zif::Scene
  def initialize
    @player
    @thrust = 2.0
    @drag = 0.9
    @angular_thrust = 0.7
    @angular_drag = 0.9
    @wall_bounce = 0.8
    @player_control = true
    @health_thrust = 1.0
    @health_ccw = 1.0
    @health_cw = 1.0

    @tile_dimensions = 64
    @map_dimensions = 5

    @ui_viewscreen_border = 32
    @ui_viewscreen_dimensions = 656
    @ui_viewscreen = {
      top: 1280 - @ui_viewscreen_border,
      right: 720 - @ui_viewscreen_border,
      bottom: 1280 - @ui_viewscreen_border - @ui_viewscreen_dimensions,
      left: @ui_viewscreen_border
    }

    @ship
    @collision_solids

    @basic_tiles = []
    @door_tiles = []
    @pickups = []

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
      :pickup_64,
      width: 64,
      height: 64
    )
    $services[:sprite_registry].register_basic_sprite(
      :mine_64,
      width: 64,
      height: 64
    )

    # @collision_solids = []

    @map = Zif::Layers::LayerGroup.new(
      tile_width: @tile_dimensions,
      tile_height: @tile_dimensions,
      logical_width: @map_dimensions,
      logical_height: @map_dimensions
    )

    @map.new_active_tiled_layer(:tiles)
    @map.new_active_layer(:doors)
    @map.new_active_layer(:ship)
    @map.new_active_layer(:pickups)

    @camera = Zif::Layers::Camera.new(
      layer_sprites: @map.layer_containing_sprites,
      initial_x: 512,
      initial_y: 512
    )

    @ship = Player.new($services[:sprite_registry].construct(:ship_64))
    $game.services.named(:action_service).register_actionable(@ship)
    @map.layers[:ship].sprites << @ship

    wall_tile = Zif::Sprite.new.tap do |s|
      s.w = 16
      s.h = 16
      s.path = 'sprites/wall-16.png'
    end

    # @map_dimensions.times do |x|
    #   @map_dimensions.times do |y|
    #     random_boolean = [true, false].sample
    #     if random_boolean
    #       # current_tile = $services[:sprite_registry].construct(:wall_16)
    #       # @map.layers[:tiles].add_positioned_sprite(
    #       #   sprite: current_tile,
    #       #   logical_x: x,
    #       #   logical_y: y
    #       # )
    #       wall = Wall.new(
    #         $services[:sprite_registry].construct(:wall2_08),
    #         x: x*@tile_dimensions,
    #         y: y*@tile_dimensions
    #       )
    #       @basic_tiles << wall
    #     end
    #   end
    # end

    # Create pickups
    # pickup = Pickup.new(
    #   $services[:sprite_registry].construct(:pickup_64),
    #   360 - 100,
    #   1000
    # )
    # @pickups << pickup
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
    @map.layers[:pickups].sprites << @pickups

    # Create doors
    door = Door.new(
      $services[:sprite_registry].construct(:doorh_128),
      360 - 64,
      1200
    )
    @door_tiles << door

    @map.layers[:doors].sprites << @door_tiles
    $gtk.args.outputs.static_sprites << @door_tiles
    # $gtk.args.outputs.static_sprites << @camera.layers

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
        @ship.angle += 90
        @ship.face_turn_ccw
        # This is for non-stepped roatation
        # @ship.add_rotation 1
      end
    end
    @button_ccw.x = 360 - 80 - @ui_viewscreen_border - 160
    @button_ccw.y = 100 + 96 + 192 + @ui_viewscreen_border
    @button_cw = ExampleApp::TallButton.new(:static_button, 160, :nine, 'CW', 2) do |point|
      if @button_cw.is_pressed
        # This is for stepped rotation, to fix later with animation states
        @ship.angle -= 90
        @ship.face_turn_cw
        # This is for non-stepped roatation
        # @ship.add_rotation -1
      end
    end
    @button_cw.x = 360 + 80 + @ui_viewscreen_border
    @button_cw.y = 128 - 192 + @ui_viewscreen_border

    # little array for buttons
    buttons = [
      @button_north,
      @button_south,
      @button_east,
      @button_west,
      @button_ccw,
      @button_cw
    ]

    # Register all buttons as Clickables
    buttons.each { |b| $game.services[:input_service].register_clickable b }

    # Render buttons to screen
    $gtk.args.outputs.static_sprites << buttons
  end

  def perform_tick
    # $gtk.add_caller_to_puts!

    # Deads cleanup
    @pickups.reject! { |p| p.is_dead }

    # stop sound if space key is pressed
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.audio[:bg_music] = nil
      # OR
      $gtk.args.audio.delete :bg_music
    end

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

    $gtk.args.outputs.sprites << @basic_tiles
    $gtk.args.outputs.sprites << @pickups
    $gtk.args.outputs.borders << @map.layers[:tiles].visible_sprites

    $gtk.args.outputs.sprites << @ship

    return if !@player_control

    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

    # Handle the basic movement.
    # The left_right and up_down convenience methods are great
    @ship.add_thrust $gtk.args.inputs.left_right, $gtk.args.inputs.up_down

    # Handle the rotation
    if $gtk.args.inputs.keyboard.l
      ($gtk.args.state.player.thrust.rotation -= @angular_thrust)
    elsif $gtk.args.inputs.keyboard.k
      ($gtk.args.state.player.thrust.rotation += @angular_thrust)
    end
    @ship.calc_rotation

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
    collision_pickups_x = $gtk.args.geometry.find_intersect_rect @ship, @pickups
    collision_pickups_x.collide_x_with @ship if collision_pickups_x

    # Check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_x @ui_viewscreen

    # and then along the y axis
    @ship.calc_positon_y

    # Check door collisions
    collision_doors_y = $gtk.args.geometry.find_intersect_rect @ship, @door_tiles
    collision_doors_y.collide_y_with @ship if collision_doors_y

    # Check pickup collisions
    collision_pickups_y = $gtk.args.geometry.find_intersect_rect @ship, @pickups
    collision_pickups_y.collide_y_with @ship if collision_pickups_y

    # check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_y @ui_viewscreen

    # Then we can apply drag
    @ship.apply_drag

    # Render the UI, which should ultimately be on a Layer rendered to
    # the static_sprites output
    $gtk.args.outputs.sprites << {
      x: 0,
      y: 0,
      w: 720,
      h: 1280,
      path: 'sprites/ui_01.png'
    }

    # This is now handled by the Zif buttons
    # $gtk.args.outputs.primitives << [@button_north, @button_south, @button_east, @button_west, @button_ccw, @button_cw]

    # Player info
    $gtk.args.outputs.debug.watch pretty_format([@ship.thrust, @ship.angle, @ship.facing]), label_style: @label_style, background_style: @background_style
  end
end
