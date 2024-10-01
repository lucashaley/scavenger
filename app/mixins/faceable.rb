module HuskEngine
  module Faceable
    FACING_KEYED = {
      north:    0,
      west:     1,
      south:    2,
      east:     3,
    }.freeze

    attr_accessor :facing

    # This is pretty ugly, but what the hell
    def face_turn_ccw
      @facing = FACING_KEYED.key((FACING_KEYED[@facing] + 1) % 4)
    end
    def face_turn_cw
      @facing = FACING_KEYED.key((FACING_KEYED[@facing] - 1) % 4)
    end
  end
end