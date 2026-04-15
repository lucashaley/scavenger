module HuskGame
  class Door < HuskSprite
    include HuskEngine::Collideable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Tickable
    include HuskEngine::Lockable
    include Zif::Traceable

    attr_accessor :room
    attr_reader :door_side, :door_buffer, :door_facing
    attr_reader :destination_node_id
    attr_reader :exit_point
    attr_reader :approached

    TOLERANCE = 8
    ENTER_DURATION = 10
    EXIT_DURATION = 20
    EXIT_OFFSET_MULTIPLIER = 0.25

    sprite_data 'door'

    def bounce
      HuskGame::Constants::BOUNCE_SCALES[@scale]
    end

    def initialize(
      scale: :large,
      door_side: :south,
      room: nil,
      destination_node_id: nil,
      husk: nil,
      locked: false
    )
      super(Zif.unique_name("Door#{door_side}"))
      @tracer_service_name = :tracer

      @door_side = door_side
      @door_tolerance = TOLERANCE
      @room = room
      @destination_node_id = destination_node_id
      @husk = husk

      @sound_bounce = HuskGame::AssetPaths::Audio::CLANK

      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bounceable
      initialize_tickable
      initialize_lockable(locked: locked, keyitem: :doorkey)

      @exit_point = { x: 0, y: 0 }

      pixel_scale = HuskGame::Constants::SPRITE_SCALES[scale]
      tile_dimensions = 640.div(pixel_scale)
      exit_offset = pixel_scale + (pixel_scale * EXIT_OFFSET_MULTIPLIER).truncate
      side_buffer = pixel_scale * 2
      side_logical = tile_dimensions - 4

      angle_delta = nil

      case @door_side
      when :north
        angle_delta = 0
        @x = (rand(side_logical) * pixel_scale) + side_buffer + 40
        @y = 1280 - 80 - pixel_scale
        @exit_point.x = @x
        @exit_point.y = @y - exit_offset
      when :south
        angle_delta = 180
        @x = (rand(side_logical) * pixel_scale) + side_buffer + 40
        @y = 1280 - 80 - 640
        @exit_point.x = @x
        @exit_point.y = @y + exit_offset
      when :east
        angle_delta = 270
        @x = 720 - 40 - pixel_scale
        @y = (rand(side_logical) * pixel_scale) + (1280 - 80 - 640) + side_buffer
        @exit_point.x = @x - exit_offset
        @exit_point.y = @y
      when :west
        angle_delta = 90
        @x = 40
        @y = (rand(side_logical) * pixel_scale) + (1280 - 80 - 640) + side_buffer
        @exit_point.x = @x + exit_offset
        @exit_point.y = @y
      end

      initialize_bufferable(:triple)

      @sprite_scale_hash.each_value do |sc|
        sc.each_value do |layer|
          layer.angle += angle_delta unless angle_delta.nil?
        end
      end

      room_name = @room ? @room.name : "node_#{@destination_node_id}"
      @name = room_name + '_door_' + @door_side.to_s

      @lights_sprite = @sprites.find { |s| s.name == "door_lights_#{scale}" }
      if @locked
        @lights_sprite.a = 0
      else
        @lights_sprite.run_animation_sequence(:idle)
      end

      update_unlocked_indicator

      @approached = false
    end

    def destination_room
      return nil unless @husk && @destination_node_id
      entrance = HuskLayout::OPPOSITE_SIDE[@door_side]
      @husk.room_for_node(@destination_node_id, entrance_side: entrance)
    end

    def destination_door
      dest = destination_room
      return nil unless dest
      opposite = HuskLayout::OPPOSITE_SIDE[@door_side]
      dest.doors_hash[opposite]
    end

    def enter_door(player)
      player.player_control = false
      player.momentum.y = 0.0
      player.momentum.x = 0.0

      player.is_dooring = true
      player.run_action(
        Zif::Actions::Action.new(
          player,
          {
            x: @x,
            y: @y
          },
          duration: ENTER_DURATION,
          easing: :smooth_stop4
        ) {
          dest_door = destination_door
          $game.scene.switch_rooms dest_door
        }
      )
    end

    def exit_door(player)
      player.x = @x
      player.y = @y
      player.run_action(
        Zif::Actions::Action.new(
          player,
          {
            x: @exit_point.x,
            y: @exit_point.y
          },
          duration: EXIT_DURATION,
          easing: :linear
        ) { player.player_control = true }
      )
    end

    def collide_action(collidee, facing)
      if can_enter_door?(collidee, facing)
        enter_door collidee
      else
        play_once @sound_bounce
        bounce_off(collidee, facing)
      end
    end

    def can_enter_door?(collidee, facing)
      return false unless facing_matches_door?(facing)
      return false unless !@locked || collidee.has_item?(@keyitem) || @husk&.all_unlocked

      aligned_with?(collidee, @door_side, @door_tolerance)
    end

    def facing_matches_door?(facing)
      vertical = [:north, :south]
      horizontal = [:east, :west]
      (vertical.include?(facing) && vertical.include?(@door_side)) ||
        (horizontal.include?(facing) && horizontal.include?(@door_side))
    end

    def perform_tick
      update_unlocked_indicator
      return if @locked && !@husk&.all_unlocked && $gtk.args.state.ship.has_item?(@keyitem) == false

      dist = $gtk.args.geometry.distance self.rect, $gtk.args.state.ship.rect
      threshold = HuskGame::Constants::SPRITE_SCALES[@scale] * 2
      if dist < threshold && @approached == false
        @approached = true
        @sprites.find { |s| s.name == "door_doors_#{scale}" }.run_animation_sequence(:open)
      elsif dist > threshold && @approached == true
        @approached = false
        @sprites.find { |s| s.name == "door_doors_#{scale}" }.run_animation_sequence(:close)
      end
    end

    def update_unlocked_indicator
      should_show = !@locked || @husk&.all_unlocked

      unlocked_sprite = @current_sprite_hash[:unlocked]
      unlocked_sprite.a = should_show ? 255 : 0 if unlocked_sprite

      if @lights_sprite
        if should_show && @lights_sprite.a == 0
          @lights_sprite.a = 255
          @lights_sprite.run_animation_sequence(:idle)
        elsif !should_show
          @lights_sprite.a = 0
        end
      end
    end

    def serialize
      {
        name: @name,
        door_side: @door_side,
        exit_point: @exit_point
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
