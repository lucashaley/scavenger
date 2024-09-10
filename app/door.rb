class Door < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Bufferable

  attr_accessor :room
  attr_accessor :door_side, :door_buffer, :door_facing
  # attr_accessor :destination_room,
  attr_accessor :destination_door
  attr_accessor :exit_point

  SPRITE_DETAILS = {
    name: "door",
    layers: [
      {
        name: "main",
        animations: [
          {
            name: "open",
            frames: 5,
            hold: 3,
            repeat: :once
          },
          {
            name: "close",
            frames: 4,
            hold: 3,
            repeat: :once
          }
        ],
        blendmode_enum: :alpha
      },
      {
        name: "lights",
        animations: [
          {
            name: "idle",
            frames: 7,
            hold: 3,
            repeat: :forever
          }
        ],
        blendmode_enum: :add
      }
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }
  # SPRITE_SCALES = {
  #   large: 64,
  #   medium: 32,
  #   small: 16
  # }
  # def sprite_scales scale
  #   SPRITE_SCALES[scale]
  # end

  def self.register_sprites
    puts "Door: Registering Sprites"

    $services[:sprite_registry].register_basic_sprite(
      "door/door_main_large",
      width: 64,
      height: 64
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_main_large",
      :door_main_large
    )

    $services[:sprite_registry].register_basic_sprite(
      "door/door_main_medium",
      width: 32,
      height: 32
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_main_medium",
      :door_main_medium
    )

    $services[:sprite_registry].register_basic_sprite(
      "door/door_main_small",
      width: 16,
      height: 16
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_main_small",
      :door_main_small
    )

    $services[:sprite_registry].register_basic_sprite(
      "door/door_lights_large",
      width: 64,
      height: 64
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_lights_large",
      :door_lights_large
    )
    $services[:sprite_registry].register_basic_sprite(
      "door/door_lights_medium",
      width: 32,
      height: 32
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_lights_medium",
      :door_lights_medium
    )
    $services[:sprite_registry].register_basic_sprite(
      "door/door_lights_small",
      width: 16,
      height: 16
    )
    $services[:sprite_registry].alias_sprite(
      "door/door_lights_small",
      :door_lights_small
    )
  end

  def initialize (
    scale: :large,
    door_side: :south,
    destination_door: nil, # there should either be a door
    room: nil # or a room, but not both
  )
    super()

    # Set variables
    @door_side = door_side
    @door_tolerance = 8

    # @bounce = BOUNCE_SCALES[scale]
    @sound_bounce = "sounds/clank.wav"

    # collate_sprites "door"
    # set_scale scale
    initialize_scaleable(scale)
    initialize_collideable
    initialize_bounceable(bounce: BOUNCE_SCALES[scale])

    @exit_point = { x: 0, y: 0 }

    pixel_scale = $SPRITE_SCALES[scale]
    tile_dimensions = 640.div(pixel_scale)
    exit_offset = pixel_scale + pixel_scale.half
    # create a buffer along the edge
    # side_length = 640 - (pixel_scale * 5)
    side_buffer = pixel_scale * 2
    side_logical = tile_dimensions - 4
    # puts "scale: #{scale}, pixel_scale: #{pixel_scale}\nside_buffer: #{side_buffer} side_logical: #{side_logical}"
    destination_side = nil

    # We need to set the rotation,
    # exit point where the player exits,
    # and the random position along the edge
    # Could this be in relative units, rendered to a render_target?

    case @door_side
    when :north
      angle_delta = 0
      @x = (rand(side_logical)*pixel_scale) + side_buffer + 40
      @y = 1280 - 80 - pixel_scale
      @exit_point.x = @x
      @exit_point.y = @y - exit_offset
      destination_side = :south
    when :south
      angle_delta = 180
      @x = (rand(side_logical)*pixel_scale) + side_buffer + 40
      @y = 1280 - 80 - 640
      @exit_point.x = @x
      @exit_point.y = @y + exit_offset
      destination_side = :north
    when :east
      angle_delta = 270
      @x = 720 - 40 - pixel_scale
      @y = (rand(side_logical)*pixel_scale) + (1280 - 80 - 640) + side_buffer
      @exit_point.x = @x - exit_offset
      @exit_point.y = @y
      destination_side = :west
    when :west
      angle_delta = 90
      @x = 40
      @y = (rand(side_logical)*pixel_scale) + (1280 - 80 - 640) + side_buffer
      @exit_point.x = @x + exit_offset
      @exit_point.y = @y
      destination_side = :east
    end
    # Now that x and y are set, we can buffer
    puts "Door.new: #{@x}, #{@y}"
    initialize_bufferable(:double)

    # Rotate the sprites
    # it might be easier to have pre-rotated sprites
    @sprite_scale_hash.each_value do |scale|
      # puts "sc: #{scale}"
      scale.each_value do |layer|
        # puts "layer: #{layer}, #{layer.angle}, #{angle_delta}"
        layer.angle += angle_delta unless angle_delta.nil?
        # ss.y += y_delta unless y_delta.nil?
      end
    end

    # Creating a new door, this will only receive either
    # a room or a door.
    # If it's a room, that means we're creating a brand new door
    # in this room, and that door will create a new destination room.
    # If it's a door,
    if destination_door.nil?
      # If there isn't a destination_door
      # then we create it
      # and that door will create a new room
      begin
        @room = room
        # @name = @room.name + '_door' + @door_side.to_s # can this be one line later?
        @destination_door = Door.new(
          scale: $SPRITE_SCALES.keys.sample.to_sym, # this is a random scale
          door_side: destination_side,
          destination_door: self
        )
      rescue => error
        puts "\n\nWELL FUCK\n========="
        puts "#{error.message}\n\n"
      end
    else
      # If there is a destination_door
      # then we create a new room
      # passing itself
      @destination_door = destination_door
      raise ArgumentError, "No destination_door: #{@name}" if destination_door.nil?

      @room = Room.new(
        name: @destination_door.room.name + '_' + @destination_door.door_side.to_s,
        chaos: @destination_door.room.chaos + 1,
        scale: scale,
        entrance_door: self
      )
      # @name = @room.name + '_door' + @door_side.to_s # can this be one line later?
    end
    @name = @room.name + '_door' + @door_side.to_s # can this be one line later?

    # create animations
    # puts "Animation: #{@sprite_scale_hash}"
    # We're going to have to dig into the sprites array of the CompoundSprite
    # and grab the named sprite
    # and add the animation to that
    # @sprite_scale_hash.select { |scale| scale[:name]}
    # puts "\n\nAnimation state: #{@sprite_scale_hash[:large][:main]}\n\n"
    # @sprite_scale_hash[:large][:main].new_basic_animation(
    #   named: :large_open,
    #   paths_and_durations: [
    #     ["door/door_main_large_open_01", 1],
    #     ["door/door_main_large_open_02", 1],
    #     ["door/door_main_large_open_03", 1],
    #     ["door/door_main_large_open_04", 1],
    #   ]
    # )
    # puts "\n\nAnimation state: #{@sprite_scale_hash[:large][:main]}\n\n"

    puts "\n\nsprites: #{@name}: \n#{sprites}\n\n"
    animation_name = "door_lights_#{scale}"
    puts sprites.find { |s| s.name == animation_name }.animation_sequences
    sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)
  end

  def create_connecting_room
    puts "create_connecting_room"
    room = Room.new(
      name: @room.name + "_" + @door_side.to_s,
      entrance_door: self,
      chaos: @room.chaos + 1, # the higher the chaos, the smaller chance of further rooms
      scale: $SPRITE_SCALES.keys.sample.to_sym # this chooses a random size
    )
  end

  def enter_door player
    # puts "enter_door: #{player}"
    # this is where we can animate entering the door
    player.player_control = false
    player.momentum.y = 0.0
    player.momentum.x = 0.0
    puts 'centering player' # we could probably use @exit_point, too.
    # player.x = center_x - (player.w.half)
    # player.y = center_y - (player.h.half)

    # Okay but we're not checking what is actually being rendered
    # Which is in the CompoundSprite.sprites array
    # puts "CURRENT SPRITES: #{sprites}"
    # the_thing = sprites.find { |s| s.name = 'door_main_large' }
    # puts the_thing.animation_sequences
    # the_thing.run_animation_sequence(:open)
    animation_name = "door_main_#{scale}"
    sprites.find { |s| s.name == animation_name }.run_animation_sequence(:open)

    # This is only working on the reference?
    # @sprite_scale_hash[:large][:main].run_animation_sequence(:open) { puts "\n\nFINISHED ANIMATION\n\n" }

    player.is_dooring = true
    puts "Is player a ship? #{player.is_a? Ship}"
    player.run_action(
      Zif::Actions::Action.new(
        player,
        {
          x: @x,
          y: @y
        },
        duration: 10,
        easing: :smooth_stop4
      ) { $game.scene.switch_rooms @destination_door }
    )

    # puts "\n\nDoor::enter_door: #{@destination_door}\n"
    # $game.scene.switch_rooms @destination_door
  end

  def exit_door player
    # puts "exit_door: #{player}"
    puts "door: #{@x}, #{@y}"
    puts "exit_point: #{@exit_point}"
    animation_name = "door_main_#{scale}"
    sprites.find { |s| s.name == animation_name }.run_animation_sequence(:close)
    # player.assign({
    #                 x: @x,
    #                 y: @y
    #               })
    player.x = @x
    player.y = @y
    player.run_action(
      Zif::Actions::Action.new(
        player,
        {
          x: @exit_point.x,
          y: @exit_point.y
        },
        duration: 20,
        easing: :linear
      ) { player.player_control = true }
    )
  end

  def collide_action collidee, facing
    puts "Door collision: #{facing} vs #{@door_side}"

    # Again, there has to be a better way
    if ((facing == :north || :south) && (@door_side == :north || :south)) ||
      ((facing == :east || :west) && (@door_side == :east || :west))

      entering = case @door_side
                 when :north, :south
                   collidee.center_x.between?(center_x - @door_tolerance, center_x + @door_tolerance)
                 when :east, :west
                   collidee.center_y.between?(center_y - @door_tolerance, center_y + @door_tolerance)
                 end

      if entering
        enter_door collidee
      else
        play_once @sound_bounce
        bounce_off(collidee, facing)
      end
    else
      play_once @sound_bounce
      bounce_off(collidee, facing)
    end
  end

  def serialize
    {
      name: @name,
      door_side: @door_side,
      # destination_door: @destination_door,
      exit_point: @exit_point
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
end
