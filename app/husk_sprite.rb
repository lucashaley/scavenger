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
  end
end
