class AnimationScene < Zif::Scene
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

    @player
    @ship
    @collision_solids

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

    # @map = Zif::Layers::LayerGroup.new(
    #   tile_width: @tile_dimensions,
    #   tile_height: @tile_dimensions,
    #   logical_width: @map_dimensions,
    #   logical_height: @map_dimensions
    # )
    #
    # @map.new_active_tiled_layer(:tiles)
    # @map.new_active_layer(:doors)
    # # @map.new_active_layer(:ship)
    # @map.new_simple_layer(:ship)
    # @map.new_active_layer(:pickups)
    #
    # @camera = Zif::Layers::Camera.new(
    #   layer_sprites: @map.layer_containing_sprites,
    #   initial_x: 512,
    #   initial_y: 512
    # )

    @ship = Ship.new()
    @ship.y = 1000
    @ship.x = 400
    $game.services.named(:action_service).register_actionable(@ship)
    # @map.layers[:ship].sprites << @ship

    # @player = Player.new($services[:sprite_registry].construct(:ship_64))
    # $game.services.named(:action_service).register_actionable(@player)
    # # @map.layers[:ship].sprites << @player
    # puts "#{$game.services.named(:action_service).actionables.length}"
    # puts "Actionables:\n#{$game.services.named(:action_service).actionables}"

    wall_tile = Zif::Sprite.new.tap do |s|
      s.w = 16
      s.h = 16
      s.path = 'sprites/wall-16.png'
    end

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
    # @map.layers[:pickups].sprites << @pickups

    # Create doors
    door = Door.new(
      $services[:sprite_registry].construct(:doorh_128),
      360 - 64,
      1200
    )
    @door_tiles << door

    # @map.layers[:doors].sprites << @door_tiles
    # $gtk.args.outputs.static_sprites << @door_tiles
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
        # @player.angle += 90
        # @player.face_turn_ccw

        # @player.rotate_ccw
        @ship.rotate_ccw
      end
    end
    @button_ccw.x = 360 - 80 - @ui_viewscreen_border - 160
    @button_ccw.y = 100 + 96 + 192 + @ui_viewscreen_border
    @button_cw = ExampleApp::TallButton.new(:static_button, 160, :nine, 'CW', 2) do |point|
      if @button_cw.is_pressed
        # This is for stepped rotation, to fix later with animation states
        # @player.angle -= 90
        # @player.face_turn_cw
        # This is for non-stepped roatation
        # @player.add_rotation -1

        # @player.rotate_cw
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
      s.path = 'sprites/ui_01.png'
    end

    # Render everything without layers
    $gtk.args.outputs.static_sprites << [
      @backdrop,
      @pickups,
      # @player,
      @ship,
      @door_tiles,
      @ui,
      @buttons
    ]
  end

  def perform_tick
    # $gtk.add_caller_to_puts!
    $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q

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
      # @player.add_thrust_y 1.0
      @ship.add_thrust_y 1.0
    end
    if @button_south.is_pressed
      # @player.add_thrust_y -1.0
      @ship.add_thrust_y -1.0
    end
    if @button_east.is_pressed
      # @player.add_thrust_x 1.0
      @ship.add_thrust_x 1.0
    end
    if @button_west.is_pressed
      # @player.add_thrust_x -1.0
      @ship.add_thrust_x -1.0
    end

    # $gtk.args.outputs.sprites << @basic_tiles
    # $gtk.args.outputs.sprites << @pickups
    # $gtk.args.outputs.borders << @map.layers[:tiles].visible_sprites
    #
    # $gtk.args.outputs.sprites << @player

    return if !@player_control

    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

    # Handle the basic movement.
    # The left_right and up_down convenience methods are great
    # @player.add_thrust $gtk.args.inputs.left_right, $gtk.args.inputs.up_down
    @ship.add_thrust $gtk.args.inputs.left_right, $gtk.args.inputs.up_down

    # Handle the rotation
    # if $gtk.args.inputs.keyboard.l
    #   ($gtk.args.state.player.thrust.rotation -= @angular_thrust)
    # elsif $gtk.args.inputs.keyboard.k
    #   ($gtk.args.state.player.thrust.rotation += @angular_thrust)
    # end
    # @player.calc_rotation
    # @ship.calc_rotation

    # animation state stuff
    # @ship.thrust_sprite.path = 'sprites/ship_thrust_01.png' if $gtk.args.inputs.keyboard.t

    # Collisions
    #
    # So the way collisions are handled are by checking for any collisions along
    # the x axis first, and then along the y.
    #
    # For each axis, check all the different layers and make things collide.

    # Check for wall collisions along the x axis first
    # @player.calc_position_x
    @ship.calc_position_x

    # Check door collisions
    # collision_doors_x = $gtk.args.geometry.find_intersect_rect @player, @door_tiles
    # collision_doors_x.collide_x_with @player if collision_doors_x
    collision_doors_x = $gtk.args.geometry.find_intersect_rect @ship, @door_tiles
    collision_doors_x.collide_x_with @ship if collision_doors_x

    # Check pickup collisions
    # collision_pickups_x = $gtk.args.geometry.find_intersect_rect @player, @pickups.reject{ |p| p.is_dead }
    # collision_pickups_x.collide_x_with @player if collision_pickups_x
    collision_pickups_x = $gtk.args.geometry.find_intersect_rect @ship, @pickups.reject{ |p| p.is_dead }
    collision_pickups_x.collide_x_with @ship if collision_pickups_x

    # Check if the player is out of screen area, and bounce them back
    # @player.bounds_inside_x @ui_viewscreen
    @ship.bounds_inside_x @ui_viewscreen

    # and then along the y axis
    # @player.calc_positon_y
    @ship.calc_positon_y

    # Check door collisions
    # collision_doors_y = $gtk.args.geometry.find_intersect_rect @player, @door_tiles
    # collision_doors_y.collide_y_with @player if collision_doors_y
    collision_doors_y = $gtk.args.geometry.find_intersect_rect @ship, @door_tiles
    collision_doors_y.collide_y_with @ship if collision_doors_y

    # Check pickup collisions
    # collision_pickups_y = $gtk.args.geometry.find_intersect_rect @player, @pickups.reject{ |p| p.is_dead }
    # collision_pickups_y.collide_y_with @player if collision_pickups_y
    collision_pickups_y = $gtk.args.geometry.find_intersect_rect @ship, @pickups.reject{ |p| p.is_dead }
    collision_pickups_y.collide_y_with @ship if collision_pickups_y

    # check if the player is out of screen area, and bounce them back
    # @player.bounds_inside_y @ui_viewscreen
    @ship.bounds_inside_y @ui_viewscreen

    # Then we can apply drag
    # @player.apply_drag
    @ship.apply_drag

    # Render the UI, which should ultimately be on a Layer rendered to
    # the static_sprites output
    # $gtk.args.outputs.sprites << {
    #   x: 0,
    #   y: 0,
    #   w: 720,
    #   h: 1280,
    #   path: 'sprites/ui_01.png'
    # }

    # $gtk.args.outputs.static_sprites << { x: 0, y: 0, h: 1280, w: 720, path: 'sprites/test_gradient.png'}
    # $gtk.args.outputs.sprites << [
    #   @pickups,
    #   @ship,
    #   @door_tiles,
    #   @buttons
    # ]

    # This is now handled by the Zif buttons
    # $gtk.args.outputs.primitives << [@button_north, @button_south, @button_east, @button_west, @button_ccw, @button_cw]

    # Player info
    # $gtk.args.outputs.debug.watch pretty_format([@ship.angle, @player.angle, @player.facing]), label_style: @label_style, background_style: @background_style
    # $gtk.args.outputs.debug.watch pretty_format(@map.layers[:ship].sprites), label_style: @label_style, background_style: @background_style
  end
end
