module HuskEngine
  module Faceable
    FACING_KEYED = {
      north:    0,
      west:     1,
      south:    2,
      east:     3,
    }.freeze

    FACING_OPPOSITES = {
      north: :south,
      south: :north,
      east:  :west,
      west:  :east,
    }.freeze

    attr_accessor :facing

    def initialize_faceable(facing)
      @facing = facing
    end

    # Returns true if two facings are opposite (e.g. :north and :south)
    def self.facing_opposite?(a, b)
      FACING_OPPOSITES[a] == b
    end

    # This is pretty ugly, but what the hell
    def face_turn_ccw
      @facing = FACING_KEYED.key((FACING_KEYED[@facing] + 1) % 4)
    end
    def face_turn_cw
      @facing = FACING_KEYED.key((FACING_KEYED[@facing] - 1) % 4)
    end
  end
end