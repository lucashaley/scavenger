module HuskGame

  # rubocop:disable Metrics/ClassLength
  class Room
    include Zif::Traceable
    include HuskEngine::Stateable

    attr_accessor :name,
                  :husk,
                  :chaos,
                  :entrance_door,
                  :tiles_target,
                  :tile_dimensions,
                  :scale,
                  :doors,
                  :doors_bits,
                  :doors_hash,
                  :no_populate_buffer,
                  :hazards,
                  :spawners,
                  :pickups,
                  :terminals,
                  :agents,
                  :dressings,
                  :decorations,
                  :overlays

    DOORS = {
      none: 0,
      north: 1,
      east: 2,
      south: 4,
      west: 8
    }.freeze
    DOOR_BITS = {
      none: 0,
      north: 1,
      east: 2,
      south: 4,
      west: 8
    }.freeze
    HAZARD_ODDS = {
      large: {
        chance: 1,
        in: 6
      },
      medium: {
        chance: 2,
        in: 5
      },
      small: {
        chance: 3,
        in: 6
      }
    }.freeze

    # rubocop:disable Metrics/MethodLength
    def initialize(
      name: 'entrance',
      husk: nil,
      chaos: 0,
      scale: :large,
      entrance_door: nil
    )
      @tracer_service_name = :tracer
      # mark_and_print("initialize")

      # Set variables
      @name = name
      @husk = husk
      @chaos = chaos
      @scale = scale
      pixel_scale = $SPRITE_SCALES[@scale]
      @tile_dimensions = 640.div(pixel_scale)
      @tiles_target = Zif::RenderTarget.new(@name, width: 640, height: 640)
      @doors = []
      @hazards = []
      @spawners = []
      @pickups = []
      @terminals = []
      @agents = []
      @dressings = []
      @decorations = []
      @overlays = []
      @doors_hash = {
        north: nil,
        south: nil,
        east: nil,
        west: nil
      }

      @no_populate_buffer = []

      create_tiles

      if entrance_door.nil?
        # Presumably we're in the entrypoint?
        breach = Breach.new
        @terminals << breach
        @no_populate_buffer << breach.buffer
        @husk.breach = breach
      end

      unless entrance_door.nil?
        @doors_hash[entrance_door.door_side] = entrance_door
        @doors << entrance_door
        @no_populate_buffer << entrance_door.buffer
      end

      populate_doors
      populate_terminals
      populate_pickups
      populate_hazards
      populate_spawners
      # populate_terminals
      populate_agents
      populate_dressings
      populate_decorations
      populate_overlays

      # This is dumping to args for Palantir
      # $gtk.args.state.rooms[@name] = { doors: @doors }

      # puts "\n\nnew room doors: #{@doors}\n\n"
      # initialize_stateable(:rooms)
    end
    # rubocop:enable Metrics/MethodLength

    def populate_doors
      # mark_and_print ("populate_doors")
      @doors_hash.each do |key, value|
        # there are no doors on this side yet
        next unless value.nil? && rand(3) + 1 > @chaos
        # Let's make a new door
        new_door = Door.new(
          scale: @scale,
          door_side: key.to_sym,
          room: self
        )
        @doors_hash[key] = new_door
        @doors << new_door
        @no_populate_buffer << new_door.buffer
      end
    end

    def find_empty_position wh=nil
      wh ||= {
        w: $SPRITE_SCALES[@scale],
        h: $SPRITE_SCALES[@scale]
      }
      # playable_x = 640 - ($SPRITE_SCALES[@scale] * 2) - $SPRITE_SCALES[@scale] # That last one is for the thing itself
      wall_doubled = $SPRITE_SCALES[@scale] * 2
      playable_x = 640 - wall_doubled - wh.w
      playable_x_margin = 40 + $SPRITE_SCALES[@scale]
      playable_y = 640 - wall_doubled - wh.h
      # playable_y = 640 - ($SPRITE_SCALES[@scale] * 2) - $SPRITE_SCALES[@scale]
      playable_y_margin = 560 + $SPRITE_SCALES[@scale]
      success = false
      loops = 0
      # puts "find_empty_position initial state: #{playable_x}, #{playable_y}, #{playable_x_margin}, #{playable_y_margin}"
      until success
        return nil if loops > 20
        temp = {
          x: rand(playable_x) + playable_x_margin,
          y: rand(playable_y) + playable_y_margin,
          # h: $SPRITE_SCALES[@scale],
          # w: $SPRITE_SCALES[@scale]
        }.merge!(wh)
        result = $gtk.args.geometry.find_intersect_rect temp, @no_populate_buffer
        loops += 1
        success = result.nil? ? true : false # returns nil if there is *no* intersection
      end
      return {
        x: temp[:x],
        y: temp[:y]
      }
    end

    def populate_pickups
      # mark_and_print "populate_pickups"
      if rand(4) <= 3
        valid_position = find_empty_position
        return if valid_position.nil?

        boost_thrust = BoostThrust.new(
          x: valid_position[:x],
          y: valid_position[:y],
          # bounce: 0.8,
          amount: 10,
          duration: 3.seconds,
          start_duration: 10,
          scale: @scale
        )
        @pickups << boost_thrust
        @no_populate_buffer << boost_thrust.buffer
      end
      # end
      valid_position = find_empty_position
      return if valid_position.nil?

      boost_emp = BoostEmp.new(
        x: valid_position[:x],
        y: valid_position[:y],
        scale: @scale
      )
      @pickups << boost_emp
      @no_populate_buffer << boost_emp.buffer
    end

    def populate_hazards
      # mark_and_print "populate_hazards"
      odds = HAZARD_ODDS[@scale] # wait, this wont give us more than one
      if rand(odds[:in]) <= odds[:chance]
        valid_position = find_empty_position
        return if valid_position.nil? # This is ganky and isn't doing what we want

        # mark_and_print "populate_hazards: creating new Mine"
        mine = HuskGame::Mine.new(
          x: valid_position[:x],
          y: valid_position[:y],
          scale: @scale
        )
        mine.deactivate
        @hazards << mine
        @no_populate_buffer << mine.buffer
      end
      if rand(4) == 3
        valid_position = find_empty_position
        return if valid_position.nil?

        repulsor = Repulsor.new(
          valid_position[:x],
          valid_position[:y],
          @scale
        )
        # mark_and_print repulsor
        repulsor.effect_target = $gtk.args.state.ship
        $game.services[:effect_service].register_effectable repulsor
        @hazards << repulsor
        @no_populate_buffer << repulsor.buffer
      end
      if rand(8) == 7
        valid_position = find_empty_position
        return if valid_position.nil?

        attractor = Attractor.new(
          valid_position[:x],
          valid_position[:y],
          @scale
        )
        # mark_and_print attractor
        attractor.effect_target = $gtk.args.state.ship
        $game.services[:effect_service].register_effectable attractor
        @hazards << attractor
        @no_populate_buffer << attractor.buffer
      end
    end

    def populate_spawners
      spawner = Spawner.new(
        x: 300,
        y: 860,
        scale: @scale,
        spawn_class: :HunterBlob,
        spawn_rate: 20.seconds,
        room: self
      )
      spawner.deactivate
      @spawners << spawner
    end

    def populate_terminals
      # mark_and_print "populate_terminals"
      if rand(1) == 0
        valid_position = find_empty_position
        return if valid_position.nil?

        data_terminal = DataTerminal.new(
          # x: rand(600) + 40 - 32,
          # y: rand(640) + 600 - 32,
          x: valid_position[:x],
          y: valid_position[:y],
          scale: @scale,
          data: rand(1000),
          data_rate: 1 + (rand(3) * 0.5), # what the hell is this computation
          facing: [:north, :south, :east, :west].sample.to_sym
          # facing: :south
        )
        data_terminal.deactivate
        @terminals << data_terminal
        @no_populate_buffer << data_terminal.buffer
      end

      if @chaos >= 3 && @husk.data_core.nil?
        valid_position = find_empty_position({ w: 128, h:128 })
        return if valid_position.nil?

        data_core = DataCore.new(
          x: valid_position[:x],
          y: valid_position[:y],
          scale: @scale,
          )
        data_core.deactivate
        @terminals << data_core
        @no_populate_buffer << data_core.buffer
        @husk.data_core = data_core
      end

      valid_position = find_empty_position
      unless valid_position.nil?
        repairer = Repairer.new(
          x: valid_position[:x],
          y: valid_position[:y],
          scale: @scale
        )
        repairer.deactivate
        @terminals << repairer
        @no_populate_buffer << repairer.buffer
      end
    end

    def populate_agents
      # mark_and_print("populate_agents")

      agent = HunterBlob.new(scale: @scale)
      agent.deactivate
      @agents << agent
    end

    def populate_dressings
      crate_min = {
        large: 0,
        medium: 2,
        small: 8
      }
      crate_max = {
        large: 3,
        medium: 6,
        small: 18
      }
      # Crates
      num = rand(crate_max[@scale]) + crate_min[@scale]
      num.times do
        valid_position = find_empty_position
        unless valid_position.nil?
          crate = Crate.new(
            x: valid_position.x,
            y: valid_position.y,
            scale: @scale
          )
          @dressings << crate
          @no_populate_buffer << crate.buffer
        end
      end

      4.times do
        valid_position = find_empty_position({ w: 128, h:128 })
        unless valid_position.nil?
          crate_big = CrateBig.new(
            x: valid_position.x,
            y: valid_position.y,
            scale: @scale
          )
          @dressings << crate_big
          @no_populate_buffer << crate_big.buffer
        end
      end
    end

    def populate_decorations
      # mark_and_print("populate_dressings")
      # Gash
      rand(2).times do
        gash = Gash.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: [:large, :medium, :small].sample
        )
        @decorations << gash
      end
      rand(2).times do
        cable01 = Cable01.new(
          x: rand(720),
          y: rand(720) + 560,
          scale: :large
        )
        @decorations << cable01
      end
    end

    def populate_overlays
      @overlays << {
        x: 40,
        y: 560,
        w: 640,
        h: 640,
        path: "sprites/overlay01/overlay01_main_large.png"
      }
    end


    def renders
      (@pickups + @hazards + @terminals).reject(&:is_dead?)
    end

    def renders_under_player
      @decorations + (@pickups + @hazards).reject(&:is_dead?) + @terminals + @dressings + @spawners
    end

    def renders_over_player
      @walls + @agents
    end

    # TODO: Clean up this weirdness
    def collidables
      @walls + (@pickups + @hazards + @agents).reject(&:is_dead?) + @terminals + @dressings
    end

    def activate
      @doors.each(&:activate)
      @pickups.each(&:activate)
      @terminals.each(&:activate)
      @hazards.each(&:activate)
      @spawners.each(&:activate)
      @agents.each(&:activate)
      @dressings.each(&:activate)
      @hazards.each { |h| h.activate_effect if h.is_a?(HuskEngine::Effectable) }
    end

    def deactivate
      @doors.each(&:deactivate)
      @pickups.each(&:deactivate)
      @terminals.each(&:deactivate)
      @hazards.each(&:deactivate)
      @agents.each(&:deactivate)
      @dressings.each(&:deactivate)
      @hazards.each { |h| h.deactivate_effect if h.is_a?(HuskEngine::Effectable) }
    end

    def purge_deads
      # puts "Bring out your dead!"
      @pickups.reject!(&:is_dead?)
      @hazards.reject!(&:is_dead?)
    end

    def serialize
      {
        name: @name
        # room_dimensions: @tile_dimensions,
        # doors: @doors,
        # chaos: @chaos
        # tiles: @tiles,
        # pickups: @pickups
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def create_tiles
      # mark_and_print "creating tiles"
      viewscreen_offset_x = 40
      viewscreen_offset_y = 560
      pixel_scale = $SPRITE_SCALES[@scale]

      # Create tiles
      @walls = []
      # @tiles = Array.new(@tile_dimensions){Array.new(@tile_dimensions)}
      @tile_dimensions.times do |x|
        @tile_dimensions.times do |y|
          if y.zero?
            # this is the south row
            @walls << if x.zero?
                        # this is the southwest corner
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :southwest,
                          scale: @scale
                        )
                      elsif x == @tile_dimensions - 1
                        # this is the southeast corner
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :southeast,
                          scale: @scale
                        )
                      else
                        # this is the south row
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :south,
                          scale: @scale
                        )
                      end
          elsif y == @tile_dimensions - 1
            # this is the north row
            @walls << if x.zero?
                        # this is the northwest corner
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :northwest,
                          scale: @scale
                        )
                      elsif x == @tile_dimensions - 1
                        # this is the northeast corner
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :northeast,
                          scale: @scale
                        )
                      else
                        # this is the north row
                        Wall.new(
                          x: (x * pixel_scale) + viewscreen_offset_x,
                          y: (y * pixel_scale) + viewscreen_offset_y,
                          # 0.8,
                          facing: :north,
                          scale: @scale
                        )
                      end
          elsif x.zero?
            # this is a middle row
            @walls << Wall.new(
              x: (x * pixel_scale) + viewscreen_offset_x,
              y: (y * pixel_scale) + viewscreen_offset_y,
              # 0.8,
              facing: :west,
              scale: @scale
            )
            # this is a west edge
          elsif x == @tile_dimensions - 1
            # this is a east edge
            @walls << Wall.new(
              x: (x * pixel_scale) + viewscreen_offset_x,
              y: (y * pixel_scale) + viewscreen_offset_y,
              # 0.8,
              facing: :east,
              scale: @scale
            )
          else
            # this is the floor
            @tiles_target.sprites << Zif::Sprite.new.tap do |s|
              s.x = x * pixel_scale
              s.y = y * pixel_scale
              s.w = pixel_scale
              s.h = pixel_scale
              s.angle = rand(4) * 90
              # s.path = "sprites/1bit_floor_#{pixel_scale}_0#{rand(6)}.png"
              s.path = "sprites/floor_#{@scale.to_s}_0#{rand(6)}.png"
            end
          end
        end
        # mark_and_print("creating_tiles done")
      end

      # This forces the creation of the containing_sprite
      # puts "\n\nContaining sprite: #{@tiles_target.containing_sprite.nil?}"
      raise ArgumentError "No containing sprite" if @tiles_target.containing_sprite.nil?
      # mark(@tiles_target.containing_sprite.nil?)
    end
  end
end