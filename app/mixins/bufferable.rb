module Bufferable
  $BUFFER_SCALES = {
    none: 0,
    whole: 1,
    double: 2
  }.freeze

  # attr_accessor :buffer_scale
  attr_reader :buffer_scale, :buffer

  def initialize_bufferable(buffer_scale)
    puts "#{@x}, #{@y}"
    raise "Bufferable received a zeroed location" if @x == 0 || @y == 0

    @buffer_scale = $BUFFER_SCALES[buffer_scale]

    sprite_scale = $SPRITE_SCALES[@scale]
    scaled_buffer = sprite_scale * @buffer_scale
    @buffer = {
      x: @x - scaled_buffer,
      y: @y - scaled_buffer,
      w: (scaled_buffer * 2) + sprite_scale,
      h: (scaled_buffer * 2) + sprite_scale,
    }
  end

  # Return the buffer around the thing
  #  _______
  #  |     |
  #  |  X  |
  #  |     |
  #  _______
  #
  # This probably should just be in the init,
  # as it only needs to happen once
  # def buffer
  #   sprite_scale = $SPRITE_SCALES[@scale]
  #   scaled_buffer = sprite_scale * @buffer_scale
  #   {
  #     x: @x - scaled_buffer,
  #     y: @y - scaled_buffer,
  #     w: (scaled_buffer * 2) + sprite_scale,
  #     h: (scaled_buffer * 2) + sprite_scale,
  #   }
  # end
end