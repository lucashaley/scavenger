class Door < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Bufferable
  include Tickable
  include Zif::Traceable

  attr_accessor :room
  attr_accessor :door_side, :door_buffer, :door_facing
  # attr_accessor :destination_room,
  attr_accessor :destination_door
  attr_accessor :exit_point
  attr_accessor :approached

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
        blendmode_enum: :alpha,
        z: 0
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
        blendmode_enum: :add,
        z: 1
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

  def initialize (
    scale: :large,
    door_side: :south,
    destination_door: nil, # there should either be a door
    room: nil # or a room, but not both
  )
    super(Zif.unique_name("Door#{door_side}"))
    @tracer_service_name = :tracer

    # Set variables
    @door_side = door_side
    @door_tolerance = 8

    # @bounce = BOUNCE_SCALES[scale]
    @sound_bounce = "sounds/clank.wav"

    # collate_sprites "door"
    # set_scale scale
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_bounceable(bounce: BOUNCE_SCALES[scale])
    initialize_tickable

    @exit_point = { x: 0, y: 0 }

    pixel_scale = $SPRITE_SCALES[scale]
    tile_dimensions = 640.div(pixel_scale)
    exit_offset = pixel_scale + (pixel_scale * 0.25).truncate
    # create a buffer along the edge
    # side_length = 640 - (pixel_scale * 5)
    side_buffer = pixel_scale * 2
    side_logical = tile_dimensions - 4

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
    # puts "Door.new: #{@x}, #{@y}"
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
      # mark_and_print room
      raise ArgumentError, "No destination room: #{@name}" if room.nil?
      # begin
        @room = room
        # @name = @room.name + '_door' + @door_side.to_s # can this be one line later?
        # mark_and_print("creating new door, no destination")
        @destination_door = Door.new(
          scale: $SPRITE_SCALES.keys.sample.to_sym, # this is a random scale
          door_side: destination_side,
          destination_door: self
        )
      # rescue => error
      #   puts "\n\nWELL FUCK\n========="
      #   mark_and_print(@name)
      #   mark_and_print (error.message)
      # end
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


    animation_name = "door_lights_#{scale}"
    @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)

    @approached = false
  end

  def create_connecting_room
    # mark_and_print "create_connecting_room"
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

    # This is now handled in perform_tick
    # animation_name = "door_main_#{scale}"
    # sprites.find { |s| s.name == animation_name }.run_animation_sequence(:open)

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
  end

  def exit_door player
    # puts "exit_door: #{player}"
    puts "door: #{@x}, #{@y}"
    puts "exit_point: #{@exit_point}"

    # this is now handled in perform_tick
    # animation_name = "door_main_#{scale}"
    # sprites.find { |s| s.name == animation_name }.run_animation_sequence(:close)

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

  def perform_tick
      dist = $gtk.args.geometry.distance self.rect, $gtk.args.state.ship.rect #$game.scene.ship.rect
      threshold = $SPRITE_SCALES[@scale] * 2
      if dist < threshold && @approached == false
        @approached = true
        @sprites.find { |s| s.name == "door_main_#{scale}" }.run_animation_sequence(:open)
        @sprites.find { |s| s.name == "door_lights_#{scale}" }.hide
      elsif dist > threshold && @approached == true
        @approached = false
        @sprites.find { |s| s.name == "door_main_#{scale}" }.run_animation_sequence(:close)
        @sprites.find { |s| s.name == "door_lights_#{scale}" }.show
        # sprites.find { |s| s.name == "door_lights_#{scale}" }.run_animation_sequence(:idle)
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
