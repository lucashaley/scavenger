module Faceable
  FACING = {
    north:    0,
    east:     1,
    south:    2,
    west:     3,
  }.freeze
  # FACING = [
  #   :north,
  #   :east,
  #   :south,
  #   :west
  # ]

  attr_accessor :facing

  # def face_turn_ccw
  #   @facing = (@facing - 1) % 4
  # end
  # def face_turn_cw
  #   @facing = (@facing + 1) % 4
  # end

  # This is pretty ugly, but what the hell
  def face_turn_ccw
    @facing = FACING.key((FACING[@facing] - 1) % 4)
  end
  def face_turn_cw
    @facing = FACING.key((FACING[@facing] + 1) % 4)
  end
end
