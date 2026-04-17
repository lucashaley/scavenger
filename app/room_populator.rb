module HuskGame
  class RoomPopulator
    HAZARD_ODDS = {
      large:  { chance: 1, in: 6 },
      medium: { chance: 2, in: 5 },
      small:  { chance: 3, in: 6 },
      tiny:   { chance: 4, in: 6 }
    }.freeze

    def initialize(room)
      @room = room
    end

    def populate
      populate_doors
      populate_terminals
      populate_pickups
      populate_hazards
      populate_spawners
      populate_agents
      populate_dressings
      populate_decorations
      populate_overlays
    end

    private

    def populate_doors
      node = @room.node
      return unless node

      node[:connections].each do |side, conn|
        next if conn.nil?
        next if @room.doors_hash[side] # already has door (entrance)

        dest_node = @room.husk.layout.node(conn[:node_id])
        new_door = Door.new(
          scale:               @room.scale,
          door_side:           side,
          room:                @room,
          destination_node_id: conn[:node_id],
          husk:                @room.husk,
          locked:              conn[:locked]
        )
        @room.doors_hash[side] = new_door
        @room.doors << new_door
        @room.no_populate_buffer << new_door.buffer
      end

      # Track whether the husk has any locked doors
      if @room.husk && @room.doors.any?(&:locked)
        @room.husk.has_locked_doors = true
      end
    end

    def find_empty_position(wh = nil, max_attempts = 100)
      wh ||= {
        w: HuskGame::Constants::SPRITE_SCALES[@room.scale],
        h: HuskGame::Constants::SPRITE_SCALES[@room.scale]
      }
      wall_doubled = HuskGame::Constants::SPRITE_SCALES[@room.scale] * 2
      playable_x = HuskGame::Constants::VIEWSCREEN_SIZE - wall_doubled - wh.w
      playable_x_margin = HuskGame::Constants::VIEWSCREEN_OFFSET_X + HuskGame::Constants::SPRITE_SCALES[@room.scale]
      playable_y = HuskGame::Constants::VIEWSCREEN_SIZE - wall_doubled - wh.h
      playable_y_margin = HuskGame::Constants::VIEWSCREEN_OFFSET_Y + HuskGame::Constants::SPRITE_SCALES[@room.scale]
      success = false
      loops = 0

      until success
        if loops > max_attempts
          puts "WARNING: find_empty_position failed after #{max_attempts} attempts for #{wh}"
          return nil
        end
        temp = {
          x: rand(playable_x) + playable_x_margin,
          y: rand(playable_y) + playable_y_margin,
        }.merge!(wh)
        result = $gtk.args.geometry.find_intersect_rect temp, @room.no_populate_buffer
        loops += 1
        success = result.nil? ? true : false
      end

      { x: temp[:x], y: temp[:y] }
    end

    # Returns a facing direction that doesn't point toward a wall closer than
    # needed for the player to stand in front of the terminal.
    # Accounts for wall thickness (one scale_px), terminal size, and player size.
    def safe_facing(x, y, w = nil, h = nil)
      scale_px = HuskGame::Constants::SPRITE_SCALES[@room.scale]
      w ||= scale_px
      h ||= scale_px
      wall = scale_px

      vs = HuskGame::Constants::VIEWSCREEN
      # Inner edges past the walls
      inner_top    = vs[:top]    - wall
      inner_bottom = vs[:bottom] + wall
      inner_right  = vs[:right]  - wall
      inner_left   = vs[:left]   + wall

      # Clearance between terminal edge and inner wall must fit the player
      candidates = []
      candidates << :north if (inner_top    - y - h) >= scale_px
      candidates << :south if (y            - inner_bottom) >= scale_px
      candidates << :east  if (inner_right  - x - w) >= scale_px
      candidates << :west  if (x            - inner_left) >= scale_px

      candidates = [:north, :south, :east, :west] if candidates.empty?
      candidates.sample.to_sym
    end

    def populate_pickups
      if rand(4) <= 3
        valid_position = find_empty_position
        return if valid_position.nil?

        boost_thrust = BoostThrust.new(
          x: valid_position[:x],
          y: valid_position[:y],
          amount: 10,
          duration: 3.seconds,
          start_duration: 10,
          scale: @room.scale
        )
        @room.pickups << boost_thrust
        @room.no_populate_buffer << boost_thrust.buffer
      end

      valid_position = find_empty_position
      return if valid_position.nil?

      boost_emp = BoostEmp.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @room.scale
      )
      @room.pickups << boost_emp
      @room.no_populate_buffer << boost_emp.buffer

      if @room.threat >= 3 && rand(4) == 0
        valid_position = find_empty_position
        unless valid_position.nil?
          boost_data = BoostData.new(x: valid_position[:x], y: valid_position[:y], scale: @room.scale)
          @room.pickups << boost_data
          @room.no_populate_buffer << boost_data.buffer
        end
      end
    end

    def populate_hazards
      odds = HAZARD_ODDS[@room.scale]
      spawn_hazard(odds[:chance], odds[:in], effectable: false) do |x, y|
        HuskGame::Mine.new(x: x, y: y, scale: @room.scale)
      end

      spawn_hazard(0, 4, effectable: true) do |x, y|
        Repulsor.new(x: x, y: y, scale: @room.scale)
      end

      spawn_hazard(0, 8, effectable: true) do |x, y|
        Attractor.new(x: x, y: y, scale: @room.scale)
      end
    end

    def spawn_hazard(chance, out_of, effectable: false)
      return unless rand(out_of) <= chance

      valid_position = find_empty_position
      return if valid_position.nil?

      hazard = yield(valid_position[:x], valid_position[:y])

      if effectable
        setup_effectable_hazard(hazard)
      else
        hazard.deactivate
        add_hazard(hazard)
      end
    end

    def add_hazard(hazard)
      @room.hazards << hazard
      @room.no_populate_buffer << hazard.buffer
    end

    def setup_effectable_hazard(hazard)
      hazard.effect_target = $gtk.args.state.ship
      $game.services[:effect_service].register_effectable hazard
      add_hazard(hazard)
    end

    def populate_spawners
      # Spawner disabled — pre-placed blobs in populate_agents are sufficient
    end

    def populate_terminals
      populate_data_terminal
      populate_data_core
      populate_repairer
      populate_unlock_terminal
    end

    def populate_data_terminal
      return unless rand(1) == 0

      valid_position = find_empty_position
      return if valid_position.nil?

      data_terminal = DataTerminal.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @room.scale,
        data: rand(1000),
        data_rate: 1 + (rand(3) * 0.5),
        facing: safe_facing(valid_position[:x], valid_position[:y])
      )
      add_terminal(data_terminal)
    end

    def populate_data_core
      return unless @room.node && @room.node[:is_data_core] && @room.husk.data_core.nil?

      valid_position = find_empty_position({ w: 128, h: 128 })
      return if valid_position.nil?

      data_core = DataCore.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @room.scale
      )
      add_terminal(data_core)
      @room.husk.data_core = data_core
    end

    def populate_repairer
      valid_position = find_empty_position
      return if valid_position.nil?

      repairer = Repairer.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @room.scale
      )
      add_terminal(repairer)
    end

    def populate_unlock_terminal
      return unless @room.node && @room.node[:is_unlock_terminal]
      return if @room.husk.nil? || @room.husk.unlock_terminal

      valid_position = find_empty_position
      return if valid_position.nil?

      facing = safe_facing(valid_position[:x], valid_position[:y])
      unlock_terminal = UnlockTerminal.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @room.scale,
        facing: facing,
        husk: @room.husk
      )
      add_terminal(unlock_terminal)
      @room.husk.unlock_terminal = unlock_terminal
    end

    def add_terminal(terminal)
      terminal.deactivate
      @room.terminals << terminal
      @room.no_populate_buffer << terminal.buffer
    end

    def populate_agents
      return if @room.threat < 2

      populate_sweepers
      populate_hunter_blobs
    end

    def populate_sweepers
      case @room.threat
      when 2
        sweeper_count = rand(2) == 0 ? 2 : 1
      when 3
        sweeper_count = rand(2) + 2
      else
        sweeper_count = rand(2) + 3
      end

      first_axis = [:horizontal, :vertical].sample
      sweeper_count.times do |i|
        valid_position = find_empty_position
        next if valid_position.nil?

        axis = i == 0 ? first_axis : Sweeper::PERPENDICULAR[first_axis]
        sweeper = Sweeper.new(x: valid_position[:x], y: valid_position[:y], scale: @room.scale, room: @room, axis: axis)
        sweeper.deactivate
        @room.agents << sweeper
        @room.no_populate_buffer << sweeper.buffer
      end
    end

    def populate_hunter_blobs
      case @room.threat
      when 2
        return
      when 3
        return unless rand(3) == 0
        count = 1
      else
        count = rand(2) == 0 ? 2 : 1
      end

      count.times do
        valid_position = find_empty_position
        next if valid_position.nil?

        agent = HunterBlob.new(x: valid_position[:x], y: valid_position[:y], scale: @room.scale)
        agent.deactivate
        @room.agents << agent
        @room.no_populate_buffer << agent.buffer
      end
    end

    def populate_dressings
      crate_min = {
        large: 0,
        medium: 2,
        small: 8,
        tiny: 12
      }
      crate_max = {
        large: 3,
        medium: 6,
        small: 18,
        tiny: 30
      }

      num = rand(crate_max[@room.scale]) + crate_min[@room.scale]
      num.times do
        valid_position = find_empty_position
        unless valid_position.nil?
          crate = Crate.new(
            x: valid_position[:x],
            y: valid_position[:y],
            scale: @room.scale
          )
          @room.dressings << crate
          @room.no_populate_buffer << crate.buffer
        end
      end

      4.times do
        valid_position = find_empty_position({ w: 128, h: 128 })
        unless valid_position.nil?
          crate_big = CrateBig.new(
            x: valid_position[:x],
            y: valid_position[:y],
            scale: @room.scale
          )
          @room.dressings << crate_big
          @room.no_populate_buffer << crate_big.buffer
        end
      end
    end

    def populate_decorations
      rand(2).times do
        gash = Gash.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: [:large, :medium, :small].sample
        )
        @room.decorations << gash
      end
      rand(2).times do
        cable01 = Cable01.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: :large
        )
        @room.decorations << cable01
      end
    end

    def populate_overlays
      @room.overlays << {
        x: HuskGame::Constants::VIEWSCREEN_OFFSET_X,
        y: HuskGame::Constants::VIEWSCREEN_OFFSET_Y,
        w: HuskGame::Constants::VIEWSCREEN_SIZE,
        h: HuskGame::Constants::VIEWSCREEN_SIZE,
        path: HuskGame::AssetPaths::Sprites::OVERLAY_01_LARGE
      }
    end
  end
end
