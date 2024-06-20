class MovementScene < Zif::Scene
  def initialize
    @player
    @thrust = 4.0
    @drag = 0.9
    @angular_thrust = 0.7
    @angular_drag = 0.9
  end

  def perform_tick
    $gtk.args.state.player.thrust.x ||= 0
    $gtk.args.state.player.thrust.y ||= 0
    $gtk.args.state.player.thrust.rotation ||= 0
    $gtk.args.state.player.rotation ||= 0

    $gtk.args.state.logo_rect ||= { x: 576,
                               y: 200,
                               w: 64,
                               h: 64 }

    $gtk.args.outputs.sprites << { x: $gtk.args.state.logo_rect.x,
                              y: $gtk.args.state.logo_rect.y,
                              w: $gtk.args.state.logo_rect.w,
                              h: $gtk.args.state.logo_rect.h,
                              path: 'sprites/ship-16.png',
                              angle: $gtk.args.state.player.rotation,
                              anchor_x: 0.5,
                              anchor_y: 0.5, }


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

    # check if the player is out of screen area, and bounce them back
    if $gtk.args.state.logo_rect.x > 720
      $gtk.args.state.logo_rect.x -= ($gtk.args.state.logo_rect.x - 720)
      $gtk.args.state.player.thrust.x *= -1
    elsif $gtk.args.state.logo_rect.x < 0
      $gtk.args.state.logo_rect.x = $gtk.args.state.logo_rect.x.abs
      $gtk.args.state.player.thrust.x *= -1
    end

    if $gtk.args.state.logo_rect.y > 1280
      $gtk.args.state.logo_rect.y -= ($gtk.args.state.logo_rect.y - 1280)
      $gtk.args.state.player.thrust.y *= -1
    elsif $gtk.args.state.logo_rect.y < 0
      $gtk.args.state.logo_rect.y = $gtk.args.state.logo_rect.y.abs
      $gtk.args.state.player.thrust.y *= -1
    end

    # Here is where we convert the thrust to movement
    # We're rendering to pixels, so let's get rid of some of those decimal points
    $gtk.args.state.player.thrust.x = ($gtk.args.state.player.thrust.x * @drag).truncate
    $gtk.args.state.player.thrust.y = ($gtk.args.state.player.thrust.y * @drag).truncate
    $gtk.args.state.player.rotation += $gtk.args.state.player.thrust.rotation
    $gtk.args.state.player.thrust.rotation = ($gtk.args.state.player.thrust.rotation * @angular_drag)
    $gtk.args.state.logo_rect.x += $gtk.args.state.player.thrust.x
    $gtk.args.state.logo_rect.y += $gtk.args.state.player.thrust.y

    $gtk.args.outputs.primitives << $gtk.args.layout.debug_primitives
    $gtk.args.outputs.debug.watch $gtk.args.state.player
  end
end
