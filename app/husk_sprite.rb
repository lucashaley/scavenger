module HuskGame
  class HuskSprite < Zif::CompoundSprite
    include HuskEngine::LazySprite
    include Zif::Traceable

    # Subclasses can call `sprite_data 'name'` instead of defining sprite_details manually
    def self.sprite_data(name)
      define_singleton_method(:sprite_details) do
        @sprite_details ||= $game.services[:sprite_data_loader].load(name)
      end
    end

    # True if `other`'s center is within `tolerance` of self on the axis
    # perpendicular to `direction`. For NS direction we check X alignment;
    # for EW direction we check Y alignment.
    def aligned_with?(other, direction, tolerance)
      case direction
      when :north, :south
        (other.center_x - center_x).abs <= tolerance
      when :east, :west
        (other.center_y - center_y).abs <= tolerance
      end
    end
  end
end
