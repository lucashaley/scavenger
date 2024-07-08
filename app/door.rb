class Door < Zif::Sprite
  include Collideable
  include Bounceable

  attr_accessor :room
  attr_accessor :door_side, :door_buffer, :door_facing
  attr_accessor :destination_room

  def initialize (
    prototype,
    x=0,
    y=0,
    bounce=0.8,
    door_side=:south,
    room=nil,
    destination=nil
  )
    super()
    assign(prototype.to_h)

    puts "\n\nInitialize Door\n==============="

    puts "\n\nCreating a new door: #{x}, #{y}, #{door_side}, #{room}"
    puts "door door_side: #{door_side}"
    puts "door room: #{room}"

    @x = x
    @y = y
    @bounce = bounce
    @sound_bounce = "sounds/clank.wav"

    @room = room
    puts "door @room: #{@room}"

    @door_side = door_side
    @door_tolerance = 8

    puts "Door exit: #{@door_side}"
    puts "destination: #{destination}"
    puts "New room: #{@room.name + "_" + @door_side.to_s}, #{@door_side}, #{@room.chaos + 1}"
    # @destination_room = Room.new(@room.name + "_" + @door_side.to_s, 10, @door_side, @room.chaos + 1)

    @destination_room = destination.nil? ?
      Room.new(@room.name + "_" + @door_side.to_s, 10, self, @room.chaos + 1) :
      destination

    puts "collision_rect: #{collision_rect}"
    initialize_collision
    puts "collision_rect: #{collision_rect}"
  end

  def set_room room
    @room = room
  end

  def set_destination room
    @destination_room = room
  end

  def collide_action collidee, facing
    puts "Door collision: #{facing} vs #{@door_side}"
    # if facing == @door_side
    # Again, there has to be a better way
    if ((facing == :north || :south) && (@door_side == :north || :south)) ||
      ((facing == :east || :west) && (@door_side == :east || :west))
      puts "Player center_y: #{collidee.center_y}"
      puts "Door center_y: #{center_y}"
      entering = case @door_side
      when :north, :south
        collidee.center_x.between?(center_x - @door_tolerance, center_x + @door_tolerance)
      when :east, :west
        collidee.center_y.between?(center_y - @door_tolerance, center_y + @door_tolerance)
      end
      # puts "entering: #{entering}"

      # if collidee.center_x.between?(center_x - @door_buffer, center_x + @door_buffer)
      if entering
        # puts "#{collidee.center_x}, #{collidee.center_y}"
        # We want to take control over the player here
        collidee.player_control = false # but this isn't a great way of doing it
        collidee.momentum.y = 0.0
        puts 'centering player'
        collidee.x = center_x - (collidee.w.half)
        collidee.y = center_y - (collidee.h.half)

        # Try to switch rooms
        puts "\n\nSwitching rooms!"
        $game.scene.switch_rooms @destination_room
        case @door_side
        when :south
          collidee.x = 360
          collidee.y = 600 + 600 - 64
        when :north
          collidee.x = 360
          collidee.y = 600 + 64
        when :west
          collidee.x = 720 - 40 - 64
          collidee.y = 600 + 320
        when :east
          collidee.x = 40
          collidee.y = 600 + 320
        end
        # collidee.x = 360
        # collidee.y = 1280 - 360
        collidee.player_control = true
      else
        play_once @sound_bounce
        bounce_off(collidee, facing)
      end
    else
      play_once @sound_bounce
      bounce_off(collidee, facing)
    end

    # Old
    # if facing == :west || facing == :east
    #   play_once @sound_bounce
    #   bounce_off(collidee, facing)
    # elsif facing == :south
    #   puts 'hitting south side'
    #   if collidee.center_x.between?(center_x - 4, center_x + 4)
    #     collidee.momentum.y = 0.0
    #     puts 'centering player'
    #     collidee.x = center_x - 32
    #     collidee.y = center_y - 64
    #   else
    #     play_once @sound_bounce
    #     bounce_off(collidee, facing) # We can probably flip order of facing
    #   end
    # end
  end
end
