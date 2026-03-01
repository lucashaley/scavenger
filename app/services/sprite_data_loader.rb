module Services
  # Loads sprite configuration data from Ruby data files
  # Provides caching for sprite details
  class SpriteDataLoader
    SPRITE_DATA_PATH = 'app/data/sprites'.freeze

    def initialize
      @cache = {}
    end

    # Load sprite details from a Ruby data file
    # @param sprite_name [String, Symbol] Name of the sprite (e.g., 'mine', 'ship')
    # @return [Hash] Sprite details
    def load(sprite_name)
      sprite_name = sprite_name.to_s

      # Return cached data if available
      return @cache[sprite_name] if @cache.key?(sprite_name)

      # Load the Ruby data file by requiring it
      file_path = "#{SPRITE_DATA_PATH}/#{sprite_name}.rb"

      # The data file should define a method that returns the sprite data
      sprite_data = eval($gtk.args.gtk.read_file(file_path))

      # Cache the result
      @cache[sprite_name] = sprite_data

      sprite_data
    end

    # Clear the cache (useful for hot-reloading in development)
    def clear_cache
      @cache.clear
    end

    # Reload a specific sprite's data
    # @param sprite_name [String, Symbol] Name of the sprite to reload
    def reload(sprite_name)
      sprite_name = sprite_name.to_s
      @cache.delete(sprite_name)
      load(sprite_name)
    end
  end
end
