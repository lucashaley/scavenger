class UiScene < Zif::Scene
  def initialize
    @player
    @thrust = 4.0
    @drag = 0.9
    @angular_thrust = 0.7
    @angular_drag = 0.9
    @wall_bounce = 0.8

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

    DEBUG_LABEL_COLOR = { r: 255, g: 255, b: 255 }.freeze
  end

  def prepare_scene
    # $gtk.args.state.player = {
    #   x: 360,
    #   y: 1000,
    #   rotation: 0,
    #   thrust: {
    #     x: 0,
    #     y: 0,
    #     rotation: 0
    #   }
    # }

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

    @ship = $services[:sprite_registry].construct(:ship_64)
    @collision_solids = []

    @map = Zif::Layers::LayerGroup.new(
      tile_width: @tile_dimensions,
      tile_height: @tile_dimensions,
      logical_width: @map_dimensions,
      logical_height: @map_dimensions
    )

    @map.new_active_tiled_layer(:tiles)
    @map.new_active_layer(:ship)

    @camera = Zif::Layers::Camera.new(
      layer_sprites: @map.layer_containing_sprites,
      initial_x: 512,
      initial_y: 512
    )

    @map.layers[:ship].sprites << @ship

    wall_tile = Zif::Sprite.new.tap do |s|
      s.w = 16
      s.h = 16
      s.path = 'sprites/wall-16.png'
    end

    @map_dimensions.times do |x|
      @map_dimensions.times do |y|
        random_boolean = [true, false].sample
        if random_boolean
          # current_tile = $services[:sprite_registry].construct(:wall_16)
          # @map.layers[:tiles].add_positioned_sprite(
          #   sprite: current_tile,
          #   logical_x: x,
          #   logical_y: y
          # )
          @basic_tiles << $services[:sprite_registry].construct(:wall2_08).assign(
            {
              x: x*@tile_dimensions,
              y: y*@tile_dimensions
            }
          )
        end
      end

      # Handle audio
      $gtk.args.audio[:bg_music] = { input: "sounds/ambient.ogg", looping: true }
    end

    # Create the navigation buttons
    # Hopefully these work with mobile touches
    @button_north = ExampleApp::TallButton.new(:static_button, 64, :white, 'N', 2)
    @button_north.x = 360 - 32
    @button_north.y = 500
    @button_south = ExampleApp::TallButton.new(:static_button, 64, :white, 'S', 2)
    @button_south.x = 360 - 32
    @button_south.y = 400
    @button_east = ExampleApp::TallButton.new(:static_button, 64, :white, 'E', 2)
    @button_east.x = 460 - 32
    @button_east.y = 450
    @button_west = ExampleApp::TallButton.new(:static_button, 64, :white, 'W', 2)
    @button_west.x = 260 - 32
    @button_west.y = 450
    @button_ccw = ExampleApp::TallButton.new(:static_button, 64, :white, 'CCW', 2) do |point|
      # is_pressed only fires once, so we can't use it for button helds
      # But it works fine for quantized rotation
      if @button_ccw.is_pressed
        $gtk.args.state.player.rotation += 90
      end
    end
    @button_ccw.x = 260 - 32
    @button_ccw.y = 500
    @button_cw = ExampleApp::TallButton.new(:static_button, 64, :white, 'CCW', 2) do |point|
      if @button_cw.is_pressed
        $gtk.args.state.player.rotation += -90
      end
    end
    @button_cw.x = 460 - 32
    @button_cw.y = 400

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

    # stop sound if space key is pressed
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.audio[:bg_music] = nil
      # OR
      $gtk.args.audio.delete :bg_music
    end

    # Handle mouse clicks in directional buttons
    # We do this in the tick because button needs to repeat while held
    if @button_north.is_pressed
      $gtk.args.state.player.thrust.y += @thrust
    end
    if @button_south.is_pressed
      $gtk.args.state.player.thrust.y += -@thrust
    end
    if @button_east.is_pressed
      $gtk.args.state.player.thrust.x += @thrust
    end
    if @button_west.is_pressed
      $gtk.args.state.player.thrust.x += -@thrust
    end

    $gtk.args.outputs.sprites << @basic_tiles

    $gtk.args.state.player ||=  { x: 576,
                                  y: 200,
                                  w: 64,
                                  h: 64,
                                  thrust: {
                                    x: 0,
                                    y: 0,
                                    rotation: 0
                                  }
                                }

    $gtk.args.state.player.thrust.x ||= 0
    $gtk.args.state.player.thrust.y ||= 0
    $gtk.args.state.player.thrust.rotation ||= 0
    $gtk.args.state.player.rotation ||= 0

    $gtk.args.outputs.solids << @collision_solids
    $gtk.args.outputs.borders << @map.layers[:tiles].visible_sprites

    @ship.x = $gtk.args.state.player.x
    @ship.y = $gtk.args.state.player.y
    @ship.angle = $gtk.args.state.player.rotation
    $gtk.args.outputs.sprites << @ship

    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

    # Handle the basic movement.
    # The left_right and up_down convenience methods are great
    $gtk.args.state.player.thrust.x += $gtk.args.inputs.left_right * @thrust
    $gtk.args.state.player.thrust.y += $gtk.args.inputs.up_down * @thrust

    # Handle the rotation
    if $gtk.args.inputs.keyboard.l
      ($gtk.args.state.player.thrust.rotation -= @angular_thrust)
    elsif $gtk.args.inputs.keyboard.k
      ($gtk.args.state.player.thrust.rotation += @angular_thrust)
    end

    # Here is where we convert the thrust to movement
    # We're rendering to pixels, so let's get rid of some of those decimal points
    $gtk.args.state.player.thrust.x = ($gtk.args.state.player.thrust.x * @drag).truncate
    $gtk.args.state.player.thrust.y = ($gtk.args.state.player.thrust.y * @drag).truncate
    $gtk.args.state.player.rotation += $gtk.args.state.player.thrust.rotation
    $gtk.args.state.player.thrust.rotation = ($gtk.args.state.player.thrust.rotation * @angular_drag)

    # check for wall collisions along the x axis first
    $gtk.args.state.player.x += $gtk.args.state.player.thrust.x

    # check if the player is out of screen area, and bounce them back
    if $gtk.args.state.player.x + $gtk.args.state.player.w > @ui_viewscreen.right
      $gtk.args.state.player.x -= ($gtk.args.state.player.x + $gtk.args.state.player.w - @ui_viewscreen.right)
      $gtk.args.state.player.thrust.x *= -1
    elsif $gtk.args.state.player.x < @ui_viewscreen.left
      $gtk.args.state.player.x += @ui_viewscreen.left - $gtk.args.state.player.x
      $gtk.args.state.player.thrust.x *= -1
    end

    collision_x = $gtk.args.geometry.find_intersect_rect $gtk.args.state.player, @basic_tiles
    # test = @map.layers[:tiles].visible_sprites(@ship).reject{ |i| i.nil? }
    # test.each {|s| s.assign({ r: 150, g: 50, b: 20 }) }
    # $gtk.args.outputs.solids << test
    # collision_x = @map.layers[:tiles].visible_sprites(@ship).first
    # collision_x = @map.layers[:tiles].find_intersect_rect(@ship)
    if collision_x
      if $gtk.args.state.player.x > collision_x.x
        $gtk.args.state.player.x -= ($gtk.args.state.player.x - $gtk.args.state.player.w - collision_x.x)
        $gtk.args.state.player.thrust.x *= -@wall_bounce
      elsif $gtk.args.state.player.x < collision_x.x
        puts "move by: #{$gtk.args.state.player.x - collision_x.x}"
        $gtk.args.state.player.x -= ($gtk.args.state.player.x + $gtk.args.state.player.w - collision_x.x)
        $gtk.args.state.player.thrust.x *= -@wall_bounce
      end
    end

    # and then along the y axis
    $gtk.args.state.player.y += $gtk.args.state.player.thrust.y

    # check if the player is out of screen area, and bounce them back
    if $gtk.args.state.player.y + $gtk.args.state.player.h > @ui_viewscreen.top
      $gtk.args.state.player.y -= ($gtk.args.state.player.y + $gtk.args.state.player.h - @ui_viewscreen.top)
      $gtk.args.state.player.thrust.y *= -1
    elsif $gtk.args.state.player.y < @ui_viewscreen.bottom
      $gtk.args.state.player.y += @ui_viewscreen.bottom - $gtk.args.state.player.y
      $gtk.args.state.player.thrust.y *= -1
    end

    collision_y = $gtk.args.geometry.find_intersect_rect $gtk.args.state.player, @basic_tiles
    # collision_y = @map.layers[:tiles].visible_sprites(@ship).first
    # collision_y = @map.layers[:tiles].find_intersect_rect(@ship)
    if collision_y
      if $gtk.args.state.player.y > collision_y.y
        $gtk.args.state.player.y -= ($gtk.args.state.player.y - $gtk.args.state.player.h - collision_y.y)
        $gtk.args.state.player.thrust.y *= -@wall_bounce
      elsif $gtk.args.state.player.y < collision_y.y
        $gtk.args.state.player.y -= ($gtk.args.state.player.y + $gtk.args.state.player.h - collision_y.y)
        $gtk.args.state.player.thrust.y *= -@wall_bounce
      end
    end

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
    # $gtk.args.outputs.debug.watch pretty_format($gtk.args.state.player), label_style: @label_style, background_style: @background_style
  end
end
