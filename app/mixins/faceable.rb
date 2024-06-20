module Faceable
  FACING = {
    north:    0,
    east:     1,
    south:    2,
    west:     3,
  }.freeze

  attr_accessor :facing

  def face_turn_ccw
    @facing = (@facing - 1) % 4
  end
  def face_turn_cw
    @facing = (@facing + 1) % 4
  end
end
