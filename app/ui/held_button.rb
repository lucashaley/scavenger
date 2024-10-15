# frozen_string_literal: true
module HuskEngine
  class HeldButton < Zif::CompoundSprite
    attr_accessor :normal, :pressed, :is_pressed

    def initialize(name=Zif.unique_name('held_button'), &block)
      super(name)
      @normal = []
      @pressed = []
      @is_pressed = false
    end
  end
end