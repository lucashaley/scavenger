module Bufferable
  $BUFFER_SCALES = {
    none: 1,
    half: 2,
    whole: 3
  }.freeze

  attr_accessor :buffer_scale

  def initialize_bufferable(buffer_scale)
    @buffer_scale = $BUFFER_SCALES[buffer_scale]
  end
  def buffer
    {
      x: @x - $SPRITE_SCALES[@scale],
      y: @y - $SPRITE_SCALES[@scale],
      w: $SPRITE_SCALES[@scale] * @buffer_scale,
      h: $SPRITE_SCALES[@scale] * @buffer_scale,
    }
  end
end