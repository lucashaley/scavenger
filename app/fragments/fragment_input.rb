# frozen_string_literal: true
module HuskGame
module FragmentInput
  def handle_meta_input
    # mark_and_print("handle_meta_input")
    # quit
    $gtk.args.gtk.request_quit if $gtk.args.inputs.keyboard.q

    # screenshot
    if $gtk.args.inputs.keyboard.key_down.space
      $gtk.args.outputs.screenshots << { x: 0, y: 0, w: 720, h: 1280, path: "sn-at-#{Kernel.tick_count}.png" }
    end

    # stop sound if space key is pressed
    if $gtk.args.inputs.keyboard.key_down.m
      raise StandardError "no bg_music" if $gtk.args.audio[:bg_music].nil?
      $gtk.args.audio[:bg_music].gain = 0.0
      @bg_music_volume = 0.0
      # OR
      # $gtk.args.audio.delete :bg_music
      $gtk.args.state.bgmusic.playing = false
    end
  end

  def handle_player_input
    # mark_and_print("handle_player_input")
    # Movement is based on thrust, so that the player continues to move
    # even after the key is released.
    # The way we handle this is by an intermediary variable between input
    # and movement, called thrust.
    # That way we can softly decrement thrust after the input stops.

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

    # Check agent collisions
    # collision_agents_y = $gtk.args.geometry.find_intersect_rect @ship, @husk.current_room.collidables

    # check if the player is out of screen area, and bounce them back
    @ship.bounds_inside_y @ui_viewscreen

    # Then we can apply drag
    @ship.apply_drag
  end
end
end