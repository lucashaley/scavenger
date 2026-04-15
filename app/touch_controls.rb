# frozen_string_literal: true
module HuskGame
  module TouchControls
    PURGE_HOLD_TICKS = 120  # 2 seconds at 60fps

    # 3x3 grid of 120px buttons, centered at GRID_CENTER
    GRID_CENTER_X = 360
    GRID_CENTER_Y = 300
    CELL_SIZE = 120

    # Grid origin (bottom-left corner of the 3x3 grid)
    GRID_X = GRID_CENTER_X - (CELL_SIZE * 3).half
    GRID_Y = GRID_CENTER_Y - (CELL_SIZE * 3).half

    # Sprite name mapping (button id → image filename part)
    SPRITE_NAMES = {
      north: 'up',
      south: 'down',
      east:  'right',
      west:  'left',
      ccw:   'ccw',
      cw:    'cw',
      emp:   'emp',
      purge: 'purge'
    }.freeze

    # Grid positions: [col, row] where row 0 = bottom, col 0 = left
    GRID_POSITIONS = {
      ccw:   [0, 2],
      north: [1, 2],
      west:  [0, 1],
      emp:   [1, 1],
      east:  [2, 1],
      purge: [0, 0],
      south: [1, 0],
      cw:    [2, 0]
    }.freeze

    BUTTON_TYPES = {
      north: :directional,
      south: :directional,
      east:  :directional,
      west:  :directional,
      ccw:   :rotational,
      cw:    :rotational,
      emp:   :functional,
      purge: :hold
    }.freeze

    POWER_SPRITE_W = 120
    POWER_SPRITE_H = 40
    POWER_TICKS_PER_BAR = 60  # 1 second at 60fps
    POWER_BAR_COUNT = 3

    def handle_ui
      $gtk.args.state.ui ||= {}
      ui = $gtk.args.state.ui
      mouse = $gtk.args.inputs.mouse
      ship = $gtk.args.state.ship
      gameplay = $gtk.args.state.gameplay

      ui.click ||= :up
      ui.purge_hold_ticks ||= 0

      ui.background ||= {
        x: GRID_X, y: GRID_Y,
        w: CELL_SIZE * 3, h: CELL_SIZE * 3,
        path: 'sprites/ui_controls/background.png'
      }

      ui.buttons ||= GRID_POSITIONS.map do |id, pos|
        create_ui_button(id, pos[0], pos[1])
      end

      ui.emp_button ||= ui.buttons.find { |b| b.id == :emp }

      if mouse.held || mouse.down
        mouse_rect = { x: mouse.x, y: mouse.y, w: 1, h: 1 }
        ui.current_button = ui.buttons.find do |b|
          $gtk.args.geometry.intersect_rect?(mouse_rect, b)
        end

        # Directional: apply thrust every frame while held
        if ui.current_button&.type == :directional
          ui.current_button.a = 180
          case ui.current_button.id
          when :north then ship.add_thrust_y(gameplay.button_thrust)
          when :south then ship.add_thrust_y(-gameplay.button_thrust)
          when :east  then ship.add_thrust_x(gameplay.button_thrust)
          when :west  then ship.add_thrust_x(-gameplay.button_thrust)
          end
        end

        # Rotational: single click
        if ui.current_button&.type == :rotational && ui.click == :up
          ui.current_button.a = 180
          case ui.current_button.id
          when :cw  then ship.rotate_cw
          when :ccw then ship.rotate_ccw
          end
        end

        # EMP: hold to charge
        if ui.current_button&.type == :functional && (ui.click == :up || ui.last_button&.id == ui.current_button.id)
          if ui.current_button.id == :emp && @ship.emp_count > 0
            ui.current_button.a = 180
            boost_emp_charge(1)
          end
        end

        # Purge: hold for 2 seconds
        if ui.current_button&.type == :hold && ui.current_button.id == :purge
          ui.current_button.a = 180
          if ship.data_blocks.length > 0
            play_voiceover(HuskGame::AssetPaths::Audio::VOICE_DATA_SLOTS_PURGING) if ui.click == :up
            ui.purge_hold_ticks += 1
            if ui.purge_hold_ticks >= PURGE_HOLD_TICKS
              ship.purge_data_blocks
              ui.purge_hold_ticks = 0
            end
          end
        else
          ui.purge_hold_ticks = 0
        end

        ui.click = :down

        if ui.current_button
          ui.last_button = ui.current_button
        else
          ui.last_button.a = 255 unless ui.last_button.nil?
          ui.current_button = nil
          ui.click = :up
        end
      end

      if mouse.up && ui.current_button
        mouse_rect = { x: mouse.x, y: mouse.y, w: 1, h: 1 }
        released_button = ui.buttons.find do |b|
          $gtk.args.geometry.intersect_rect?(mouse_rect, b)
        end

        released_button.a = 255 if released_button

        if released_button&.type == :functional && released_button.id == :emp
          handle_emp
        end

        ui.purge_hold_ticks = 0
        ui.current_button = nil
        ui.click = :up
      end
    end

    def boost_emp_charge(amount)
      gameplay = $gtk.args.state.gameplay
      @emp_power += amount
      @emp_power = @emp_power.clamp(0, gameplay.max_emp_power)
    end

    def render_purge_button
      ui = $gtk.args.state.ui
      ship = $gtk.args.state.ship
      progress = (ui.purge_hold_ticks || 0).fdiv(PURGE_HOLD_TICKS).clamp(0, 1)

      return [] if progress <= 0

      purge_btn = ui.buttons.find { |b| b.id == :purge }
      return [] unless purge_btn

      # Progress fill over the purge button
      [{
        x: purge_btn.x, y: purge_btn.y,
        w: (CELL_SIZE * progress).truncate, h: CELL_SIZE,
        r: 200, g: 40, b: 40, a: 120,
        path: :solid
      }]
    end

    def render_power_indicators
      base_x = GRID_X + CELL_SIZE * 2
      base_y = GRID_Y + CELL_SIZE * 2

      output = []
      POWER_BAR_COUNT.times do |i|
        y = base_y + (i * POWER_SPRITE_H)

        # Always render base bar
        output << {
          x: base_x,
          y: y,
          w: POWER_SPRITE_W,
          h: POWER_SPRITE_H,
          path: "sprites/ui_controls/ui_power_0#{i + 1}.png",
          a: 255
        }

        # Overlay lit version when charged
        threshold = (i + 1) * POWER_TICKS_PER_BAR
        next if @emp_power < threshold

        output << {
          x: base_x,
          y: y,
          w: POWER_SPRITE_W,
          h: POWER_SPRITE_H,
          path: "sprites/ui_controls/ui_power_0#{i + 1}_on.png",
          blendmode_enum: 2,
          a: 255
        }
      end
      output
    end

    def create_ui_button(id, col, row)
      sprite_name = SPRITE_NAMES[id]
      bx = GRID_X + col * CELL_SIZE
      by = GRID_Y + row * CELL_SIZE

      {
        name: id.to_s,
        id: id,
        x: bx,
        y: by,
        w: CELL_SIZE,
        h: CELL_SIZE,
        path: "sprites/ui_controls/ui_button_#{sprite_name}_up.png",
        a: 255,
        type: BUTTON_TYPES[id]
      }
    end
  end
end
