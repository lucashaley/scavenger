module HuskGame
  class HuskSprite < Zif::CompoundSprite
    include HuskEngine::LazySprite
    include Zif::Traceable
  end
end
