module HuskEngine
  module Bufferable
    $BUFFER_SCALES = {
      none: 0,
      single: 1,
      double: 2,
      triple: 3
    }.freeze

    # attr_accessor :buffer_scale
    attr_reader :buffer_scale, :buffer

    def initialize_bufferable(buffer_scale)
      # puts "#{@x}, #{@y}"
      raise ArgumentError unless $BUFFER_SCALES.key?(buffer_scale)
      raise "Bufferable received a zeroed location" if @x == 0 || @y == 0

      @buffer_scale = $BUFFER_SCALES[buffer_scale] # 3

      # sprite_scale = $SPRITE_SCALES[@scale] # 32
      sprite_scale = self.class::SPRITE_DETAILS[:scales][scale]
      # scaled_buffer = sprite_scale * @buffer_scale # 96
      scaled_buffer = sprite_scale.transform_values { |v| v * @buffer_scale }
      @buffer = {
        x: @x - scaled_buffer.w,
        y: @y - scaled_buffer.h,
        w: (scaled_buffer.w * 2) + sprite_scale.w,
        h: (scaled_buffer.h * 2) + sprite_scale.h,
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
end