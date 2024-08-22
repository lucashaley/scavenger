# frozen_string_literal: true

class DataTerminal < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Faceable

  attr_reader :data

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }.freeze

  def initialize(
    x: 0,
    y: 0,
    scale: :large,
    facing: :south,
    data: 100
  )
    puts "\n\nDataTerminal Initialize\n======================"
    super()

    collate_sprites 'dataterminal'
    set_scale scale
    initialize_collideable
    initialize_bounceable(bounce: 0.3, sound_bounce: 'sounds/thump.wav')

    # variable assign
    @x = x
    @y = y
    @facing = facing
    @data = data
    @data_hold_time = 1000
    @previous_data_tick = 0

    @bounce = 0.7
    @sound_collide = "sounds/thump.wav"

    @sound_pickup_success = "sounds/pickup.wav"
  end

  def collide_action(collidee, collided_on)
    puts "DataTerminal: collide_action: #{collided_on}"
    puts "previous_tick: #{@previous_data_tick}"

    # Get the turret direction from the player
    # and compare it to the collision facing
    if (collidee.facing == :north && collided_on == :south && @facing == :south) ||
      (collidee.facing == :south && collided_on == :north && @facing == :north) ||
      (collidee.facing == :west && collided_on == :east && @facing == :east) ||
      (collidee.facing == :east && collided_on == :west && @facing == :west)
      # play_once @sound_pickup_success

      puts "\nWE HAVE DATA CONNECTION\n\n"
      puts Kernel.tick_count - @previous_data_tick

      if Kernel.tick_count - @previous_data_tick <= @data_hold_time
        puts "\n\nLOADING DATA\n\n"
        @collision_enabled = false
        collidee.player_control = false
        collidee.momentum.y = 0.0
        collidee.momentum.x = 0.0
      end

      @previous_data_tick = Kernel.tick_count
    else
      # play_once @sound_collide
      bounce_off(collidee, collided_on)
    end
  end
end