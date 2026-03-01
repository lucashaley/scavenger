module HuskEngine
  module LazySprite
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def const_missing(name)
        if name == :SPRITE_DETAILS
          const_set(:SPRITE_DETAILS, sprite_details)
        else
          super
        end
      end

      def const_defined?(name, inherit = true)
        return true if name == :SPRITE_DETAILS
        super
      end
    end
  end
end
