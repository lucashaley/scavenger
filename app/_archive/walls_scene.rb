class WallsScene < Zif::Scene
  def initialize
    @player
    @thrust = 4.0
    @drag = 0.9
    @angular_thrust = 0.7
    @angular_drag = 0.9
    @wall_bounce = 0.8

    @tile_dimensions = 64
    @map_dimensions = 5

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
  end

  def prepare_scene
    $services[:sprite_registry].register_basic_sprite(
      :ship2_08,
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

    @ship = $services[:sprite_registry].construct(:ship2_08)
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
    end

    # @camera = Zif::Layers::Camera.new(
    #   layer_sprites: @map.layer_containing_sprites,
    #   # starting_width: 400,
    #   # starting_height: 400,
    #   # initial_x: 560,
    #   # initial_y: 640
    # )

    # $gtk.args.outputs.static_sprites << @map.layer_containing_sprites

    # $gtk.args.outputs.static_sprites << @camera.layers
  end

  def perform_tick
    # $gtk.add_caller_to_puts!

    # # This is a really weird thing where the right edge gets cut off after 96 px
    # $gtk.args.outputs.borders << {
    #   x: @map.layers[:tiles].x,
    #   y: @map.layers[:tiles].y,
    #   w: @map.layers[:tiles].w - 95,
    #   h: @map.layers[:tiles].h,
    #   r: 0,
    #   g: 255,
    #   b: 0
    # }

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
    if $gtk.args.state.player.x + $gtk.args.state.player.w > 720
      $gtk.args.state.player.x -= ($gtk.args.state.player.x - 720 + $gtk.args.state.player.w)
      $gtk.args.state.player.thrust.x *= -1
    elsif $gtk.args.state.player.x < 0
      $gtk.args.state.player.x = $gtk.args.state.player.x.abs
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
    if $gtk.args.state.player.y + $gtk.args.state.player.h > 1280
      $gtk.args.state.player.y -= ($gtk.args.state.player.y - 1280 + $gtk.args.state.player.h)
      $gtk.args.state.player.thrust.y *= -1
    elsif $gtk.args.state.player.y < 0
      $gtk.args.state.player.y = $gtk.args.state.player.y.abs
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

    $gtk.args.outputs.debug.watch pretty_format($gtk.args.state.player), label_style: @label_style, background_style: @background_style
  end
end
