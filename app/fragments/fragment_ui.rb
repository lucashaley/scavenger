# frozen_string_literal: true
module HuskGame
  module FragmentUi
    def handle_ui
      $gtk.args.state.ui ||= {}
      ui = $gtk.args.state.ui
      mouse = $gtk.args.inputs.mouse
      ship = $gtk.args.state.ship
      gameplay = $gtk.args.state.gameplay

      ui.click ||= :up

      # assemble the statics
      ui.statics ||= {
        buttons_offset: { x: 240, y: 320 },
        directional_padding: 118,
        rotational_padding: 110
      }

      ui.buttons ||= [
        create_ui_button(
          id: :north,
          x: 0 + ui.statics.buttons_offset.x,
          y: ui.statics.buttons_offset.y + ui.statics.directional_padding,
          w: 184,
          h: 113,
          click_radius: 40,
          type: :directional
        ),
        create_ui_button(
          id: :south,
          x: 0 + ui.statics.buttons_offset.x,
          y: ui.statics.buttons_offset.y - ui.statics.directional_padding,
          w: 184,
          h: 113,
          click_radius: 40,
          type: :directional
        ),
        create_ui_button(
          id: :east,
          x: ui.statics.buttons_offset.x + ui.statics.directional_padding,
          y: ui.statics.buttons_offset.y,
          w: 113,
          h: 184,
          click_radius: 40,
          type: :directional
        ),
        create_ui_button(
          id: :west,
          x: ui.statics.buttons_offset.x - ui.statics.directional_padding,
          y: ui.statics.buttons_offset.y,
          w: 113,
          h: 184,
          click_radius: 40,
          type: :directional
        ),
        create_ui_button(
          id: :ccw,
          x: ui.statics.buttons_offset.x - ui.statics.rotational_padding,
          y: ui.statics.buttons_offset.y + ui.statics.rotational_padding,
          w: 166,
          h: 166,
          click_center: [-30, 30],
          click_radius: 40,
          type: :rotational
        ),
        create_ui_button(
          id: :cw,
          x: ui.statics.buttons_offset.x + ui.statics.rotational_padding,
          y: ui.statics.buttons_offset.y - ui.statics.rotational_padding,
          w: 166,
          h: 166,
          click_center: [30, -30],
          click_radius: 40,
          type: :rotational
        ),
        create_ui_button(
          id: :emp,
          x: ui.statics.buttons_offset.x,
          y: ui.statics.buttons_offset.y,
          w: 110,
          h: 110,
          click_radius: 40,
          type: :functional
        ),
      ]

      ui.statuses ||= {
        emp_charge: create_ui_status(
          id: :emp_charge,
          x: ui.statics.buttons_offset.x + ui.statics.rotational_padding,
          y: ui.statics.buttons_offset.y + ui.statics.rotational_padding,
          h: 166,
          w: 166
        )
      }

      # reset button down states

      if mouse.held || mouse.down
        # puts "ui.click: #{ui.click}"

        # which button are we pressing?
        ui.current_button = ui.buttons.find do |b|
          mouse.inside_circle? b.click_center, b.click_radius
        end
        # puts "current button: #{ui.current_button}"

        # The player can hold down and move around directionally
        if ui.current_button&.type == :directional && ui.last_button.type == :directional
          ui.current_button.path = ui.current_button.path_down
          case ui.current_button.id
          when :north
            ship.add_thrust_y(gameplay.button_thrust)
          when :south
            ship.add_thrust_y(-gameplay.button_thrust)
          when :east
            ship.add_thrust_x(gameplay.button_thrust)
          when :west
            ship.add_thrust_x(-gameplay.button_thrust)
          else
            raise StandardError "Directional button pressed is not recognized"
          end
        end

        # the rotation buttons need to be clicked separately
        if ui.current_button&.type == :rotational && ui.click == :up
          ui.current_button.path = ui.current_button.path_down
          case ui.current_button.id
          when :cw
            ship.rotate_cw
          when :ccw
            ship.rotate_ccw
          else
            raise StandardError "Rotational button not recognized"
          end
        end

        # Handle emp charging
        if ui.current_button&.type == :functional && (ui.click == :up || ui.last_button&.id == ui.current_button.id)
          case ui.current_button.id
          when :emp
            if @ship.emp_count > 0
              ui.current_button.path = ui.current_button.path_down
              # @emp_power += 1
              boost_emp_charge(1)
            end
          else
            raise StandardError "Functional button not recognized"
          end
        end

        # Prepare to check for separate clicks
        ui.click = :down

        # TODO: Something off here
        # Probably should move the ui.click = :down above here
        # And set ui.click = :up if moved away
        # The issue is that you can mouse down *not* on a button
        # Then move onto a button
        # check if click has moved too far away
        if ui.current_button
          ui.last_button = ui.current_button
        else
          # mouse has moved too far from the button
          ui.last_button.path = ui.last_button.path_up unless ui.last_button.nil?
          ui.current_button = nil
          ui.click = :up
        end

        # # Prepare to check for separate clicks
        # ui.click = :down
      end

      if mouse.up && ui.current_button
        released_button = ui.buttons.find do |b|
          mouse.inside_circle? b.click_center, b.click_radius
        end

        if released_button
          released_button.path = released_button.path_up
        end

        if released_button&.type == :functional
          # handle the function
          case released_button.id
          when :emp
            handle_emp
          end
        end

        ui.current_button = nil
        ui.click = :up
      end

      handle_statuses
    end

    def handle_statuses
      # emp charge
      ui = $gtk.args.state.ui
      gameplay = $gtk.args.state.gameplay
      emp_status_level = ((@emp_power / gameplay.max_emp_power) * 3).truncate
      ui.statuses.emp_charge.path = "sprites/playercontrols/emp_charge_0#{emp_status_level}.png"

      # TODO: this is finding every tick? UGH
      # emp button
      emp_button = ui.buttons.find do |b|
        b.id == :emp
      end
      if @ship.emp_count <= 0 && emp_button
        emp_button.path = "sprites/playercontrols/emp_none.png"
      end
    end

    def boost_emp_charge(amount)
      puts "boost emp charge: #{amount}"
      gameplay = $gtk.args.state.gameplay
      @emp_power += amount
      @emp_power = @emp_power.clamp(0, gameplay.max_emp_power)
    end

    def create_ui_button(
      id: nil,
      x: 0,
      y: 0,
      w: 0,
      h: 0,
      click_center: nil,
      click_radius: 0,
      type: :none
    )
      {
        name: id.to_s,
        id: id,
        x: x - w.half,
        y: y - h.half,
        w: w,
        h: h,
        path_up: "sprites/playercontrols/#{id.to_s}_up.png",
        path_down: "sprites/playercontrols/#{id.to_s}_down.png",
        path: "sprites/playercontrols/#{id.to_s}_up.png",
        state: :up,
        click_center: click_center.nil? ? [x, y] : click_center.add_2d([x, y]),
        click_radius: click_radius,
        type: type,
        is_pressed: false
      }
    end

    def create_ui_status(
      id: nil,
      x: 0,
      y: 0,
      w: 0,
      h: 0
    )
      {
        name: id.to_s,
        id: id,
        x: x - w.half,
        y: y - h.half,
        w: w,
        h: h,
        path: "sprites/playercontrols/#{id.to_s}_00.png",
      }
    end
  end
end
