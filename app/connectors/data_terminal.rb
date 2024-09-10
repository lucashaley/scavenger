# frozen_string_literal: true

class DataTerminal < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Scaleable
  include Faceable
  include Bufferable

  attr_reader :interfacing, :data, :data_rate, :tolerance

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }.freeze

  SPRITE_DETAILS = {
    name: "dataterminal",
    layers: [
      {
        name: "main",
      },
    ],
    scales: [
      :large,
      :medium,
      :small,
    ]
  }.freeze

  def self.register_sprites
    puts "DataTerminal: Registering Sprites"

    $services[:sprite_registry].register_basic_sprite(
      "dataterminal/dataterminal_main_large",
      width: 64,
      height: 64
    )
    $services[:sprite_registry].alias_sprite(
      "dataterminal/dataterminal_main_large",
      :dataterminal_main_large
    )

    $services[:sprite_registry].register_basic_sprite(
      "dataterminal/dataterminal_main_medium",
      width: 32,
      height: 32
    )
    $services[:sprite_registry].alias_sprite(
      "dataterminal/dataterminal_main_medium",
      :dataterminal_main_medium
    )

    $services[:sprite_registry].register_basic_sprite(
      "dataterminal/dataterminal_main_small",
      width: 16,
      height: 16
    )
    $services[:sprite_registry].alias_sprite(
      "dataterminal/dataterminal_main_small",
      :dataterminal_main_small
    )
  end

  def initialize(
    x: 0,
    y: 0,
    scale: :large,
    facing: :south,
    tolerance: 4,
    data: 1000,
    data_rate: 2
  )
    puts "\n\nDataTerminal Initialize\n======================"
    super()
    @x = x
    @y = y

    # collate_sprites 'dataterminal' + facing.to_s
    # set_scale scale
    initialize_scaleable(scale)
    initialize_collideable
    initialize_bounceable(bounce: 0.3, sound_bounce: 'sounds/thump.wav')
    initialize_bufferable(:double)

    # variable assign
    @facing = facing

    @interfacing = false
    @data = data
    @remaining_data = data
    @corrupted = false
    @data_rate = data_rate
    @data_hold_time = 10
    @tolerance = tolerance
    # @previous_data_tick = 0

    @bounce = 0.7
    @sound_collide = "sounds/thump.wav"

    @sound_pickup_success = "sounds/pickup.wav"

    # puts @sprite_scale_hash.keys
  end

  def collide_action(collidee, collided_on)
    # puts "DataTerminal: collide_action: #{collided_on}"
    # puts "previous_tick: #{@previous_data_tick}"

    # Get the turret direction from the player
    # and compare it to the collision facing
    if ((collidee.facing == :north && collided_on == :south && @facing == :south) ||
      (collidee.facing == :south && collided_on == :north && @facing == :north) ||
      (collidee.facing == :west && collided_on == :east && @facing == :east) ||
      (collidee.facing == :east && collided_on == :west && @facing == :west)) && @remaining_data > 0

      # This stops the overlap and bounce, and the weird y collision stuff
      # This would all be easier if we did predictive collision, instead of reactive
      case @facing
      when :north
        collidee.y = @y + @h
        collidee.momentum.y = 0.0
      when :south
        collidee.y = @y - collidee.h
        collidee.momentum.y = 0.0
      when :east
        collidee.x = @x + @w
        collidee.momentum.x = 0.0
      when :west
        collidee.x = @x - collidee.w
        collidee.momentum.x = 0.0
      end

      # This is ripped from the door
      # Possible chance of optimization/refactor
      entering = case facing
                 when :north, :south
                   collidee.center_x.between?(center_x - @tolerance, center_x + @tolerance)
                 when :east, :west
                   collidee.center_y.between?(center_y - @tolerance, center_y + @tolerance)
                 end

      if entering
        @previous_data_tick ||= Kernel.tick_count

        # If the data isn't collected all in one go, there is a chance the data gets corrupted.
        if Kernel.tick_count - @previous_data_tick <= @data_hold_time

          @interfacing = true

          collidee.add_data(@data_rate)
          # @data -= @data_rate
          @remaining_data -= @data_rate

          if @remaining_data <= 0
            # the data block has been collected

            collidee.add_data_block(name: @name, size: @data, corrupted: @corrupted)
            audio_feedback = @corrupted ? "sounds/data_corrupted.wav" : "sounds/data_collected.wav"
            play_once audio_feedback
          end
        else
          # there is a chance the data has been corrupted
          @corrupted |= rand(3) == 0
          puts "Has been corrupted? #{@corrupted}"
        end

        @previous_data_tick = Kernel.tick_count
      end # entering
    else
      # play_once @sound_collide
      bounce_off(collidee, collided_on)
    end
  end
end