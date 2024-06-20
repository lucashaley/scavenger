class Door < Zif::Sprite
  include Collideable
  include Bounceable

  attr_accessor :door_side, :door_buffer

  def initialize (
    prototype,
    x=0,
    y=0,
    bounce=0.8,
    door_side=Faceable::FACING::south
  )
    puts 'Wall initialize'
    puts x
    puts y
    puts bounce
    super()
    assign(prototype.to_h)

    @x = x
    @y = y
    @bounce = bounce
    @sound_bounce = "sounds/clank.wav"

    @door_side = door_side
    @door_buffer = 4
  end

  def collide_action collidee, facing
    # puts "Door collision: #{facing} vs #{@door_side}"
    if facing == @door_side
      # puts "Player center_y: #{collidee.center_y}"
      # puts "Door center_y: #{center_y}"
      entering = case @door_side
      when Faceable::FACING::north, Faceable::FACING::south
        collidee.center_x.between?(center_x - @door_buffer, center_x + @door_buffer)
      when Faceable::FACING::east, Faceable::FACING::west
        collidee.center_y.between?(center_y - @door_buffer, center_y + @door_buffer)
      end
      # puts "entering: #{entering}"

      # if collidee.center_x.between?(center_x - @door_buffer, center_x + @door_buffer)
      if entering
        # puts "#{collidee.center_x}, #{collidee.center_y}"
        # We want to take control over the player here
        collidee.player_control = false # but this isn't a great way of doing it
        collidee.momentum.y = 0.0
        puts 'centering player'
        collidee.x = center_x - (collidee.w * 0.5)
        collidee.y = center_y - (collidee.h * 0.5)
      else
        play_once @sound_bounce
        bounce_off(collidee, facing)
      end
    else
      play_once @sound_bounce
      bounce_off(collidee, facing)
    end

    # Old
    # if facing == Faceable::FACING::west || facing == Faceable::FACING::east
    #   play_once @sound_bounce
    #   bounce_off(collidee, facing)
    # elsif facing == Faceable::FACING::south
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
