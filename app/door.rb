class Door < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable

  attr_accessor :room
  attr_accessor :door_side, :door_buffer, :door_facing
  # attr_accessor :destination_room,
  attr_accessor :destination_door
  attr_accessor :exit_point

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
    super()

    # Set variables
    @door_side = door_side
    @door_tolerance = 8

    @bounce = BOUNCE_SCALES[scale]
    @sound_bounce = "sounds/clank.wav"

    collate_sprites "door"
    set_scale scale

    @exit_point = { x: 0, y: 0 }

    pixel_scale = $SPRITE_SCALES[scale]
    tile_dimensions = 640.div(pixel_scale)
    exit_offset = pixel_scale + pixel_scale.half
    # create a buffer along the edge
    # side_length = 640 - (pixel_scale * 5)
    side_buffer = pixel_scale * 2
    side_logical = tile_dimensions - 4
    puts "scale: #{scale}, pixel_scale: #{pixel_scale}\nside_buffer: #{side_buffer} side_logical: #{side_logical}"
    destination_side = nil

    # We need to set the rotation,
    # exit point where the player exits,
    # and the random position along the edge
    # Could this be in relative units, rendered to a render_target?

    case @door_side
    when :north
      @x = (rand(side_logical)*pixel_scale) + side_buffer + 40
      @y = 1280 - 80 - pixel_scale
      @exit_point.x = @x
      @exit_point.y = @y + exit_offset
      destination_side = :south
    when :south
      angle_delta = 180
      @x = (rand(side_logical)*pixel_scale) + side_buffer + 40
      @y = 1280 - 80 - 640
      @exit_point.x = @x
      @exit_point.y = @y - exit_offset
      destination_side = :north
    when :east
      angle_delta = 270
      @x = 720 - 40 - pixel_scale
      @y = (rand(side_logical)*pixel_scale) + (1280 - 80 - 640) + side_buffer
      @exit_point.x = @x + exit_offset
      @exit_point.y = @y
      destination_side = :west
    when :west
      angle_delta = 90
      @x = 40
      @y = (rand(side_logical)*pixel_scale) + (1280 - 80 - 640) + side_buffer
      @exit_point.x = @x - exit_offset
      @exit_point.y = @y
      destination_side = :east
    end
    # Rotate the sprites
    # it might be easier to have pre-rotated sprites
    @sprite_scale_hash.each_value do |sc|
      # puts "sc: #{sc}"
      sc.each_value do |ss|
        ss.angle += angle_delta unless angle_delta.nil?
        # ss.y += y_delta unless y_delta.nil?
      end
    end

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
      @room = Room.new(
        name: @destination_door.room.name + '_' + @destination_door.door_side.to_s,
        chaos: @destination_door.room.chaos + 1,
        scale: $SPRITE_SCALES.keys.sample.to_sym,
        entrance_door: self
      )
      # @name = @room.name + '_door' + @door_side.to_s # can this be one line later?
    end
    @name = @room.name + '_door' + @door_side.to_s # can this be one line later?
    puts "name: #{@name}"
  end

  # def initialize (
  #   x: 0,
  #   y: 0,
  #   bounce: 0.8,
  #   room: nil,
  #   door_side: :south,
  #   # connecting_door: nil,
  #   scale: :large
  # )
  #   puts "\n\Door Initialize\n======================"
  #   super()
  #
  #   @x = x
  #   @y = y
  #   @room = room
  #   @door_side = door_side
  #   @door_tolerance = 8
  #
  #   @bounce = bounce
  #   @sound_bounce = "sounds/clank.wav"
  #
  #   collate_sprites "door"
  #   set_scale scale
  #
  #   @exit_point = { x: 0, y: 0 }
  #   pixel_scale = SPRITE_SCALES[@scale]
  #   exit_offset = pixel_scale + pixel_scale.half
  #   case @door_side
  #   when :south
  #     angle_delta = 180
  #     @exit_point.x = @x
  #     @exit_point.y = @y - exit_offset
  #   when :east
  #     angle_delta = 270
  #     @exit_point.x = @x + exit_offset
  #     @exit_point.y = @y
  #   when :west
  #     angle_delta = 90
  #     @exit_point.x = @x - exit_offset
  #     @exit_point.y = @y
  #   when :north
  #     @exit_point.x = @x
  #     @exit_point.y = @y + exit_offset
  #   end
  #   puts "exit_point: #{@exit_point}"
  #
  #   # Rotate the sprites
  #   # it might be easier to have pre-rotated sprites
  #   @sprite_scale_hash.each_value do |sc|
  #     # puts "sc: #{sc}"
  #     sc.each_value do |ss|
  #       ss.angle += angle_delta unless angle_delta.nil?
  #       # ss.y += y_delta unless y_delta.nil?
  #     end
  #   end
  #
  #   # this should be consolidated into just the door
  #   # @connecting_door = connecting_door
  #
  #   # @destination_room = connecting_door.nil? ? create_connecting_room : connecting_door.room
  #   # @connecting_door = connecting_door.nil? ? create_connecting_room : connecting_door
  #
  #   # set_scale scale
  #
  #
  # end

  def create_connecting_room
    puts "create_connecting_room"
    room = Room.new(
      name: @room.name + "_" + @door_side.to_s,
      referring_door: self,
      chaos: @room.chaos + 1, # the higher the chaos, the smaller chance of further rooms
      scale: $SPRITE_SCALES.keys.sample.to_sym # this chooses a random size
    )
  end

  def enter_door player
    # puts "enter_door: #{player}"
    # this is where we can animate entering the door
    player.player_control = false
    player.momentum.y = 0.0
    puts 'centering player'
    player.x = center_x - (player.w.half)
    player.y = center_y - (player.h.half)

    puts "\n\nSwitching rooms: #{@destination_door}\n"
    $game.scene.switch_rooms @destination_door
  end

  def exit_door player
    puts "exit_door: #{player}"
    # this is where we might animate the player exiting
    player.assign(@exit_point)
    player.player_control = true
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
        # # We want to take control over the player here
        # collidee.player_control = false # but this isn't a great way of doing it
        # collidee.momentum.y = 0.0
        # puts 'centering player'
        # collidee.x = center_x - (collidee.w.half)
        # collidee.y = center_y - (collidee.h.half)
        #
        # # This is where we'd animate the drone entering the door
        #
        # puts "connecting_door: #{@connecting_door}"
        #
        # # Try to switch rooms
        # puts "\n\nSwitching rooms: #{@destination_room}, #{@connecting_door}\n"
        # $game.scene.switch_rooms @destination_room, @connecting_door.exit_point
        # puts "Are we getting here?"
        #
        # # We'll want to return control elsewhere, this is weird
        # collidee.player_control = true
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
