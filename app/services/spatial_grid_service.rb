module Services
  # Spatial partitioning service to optimize collision detection
  # Divides the game world into a grid and tracks which objects are in which cells
  class SpatialGridService
    attr_reader :cell_size, :grid

    def initialize(cell_size: 128)
      @cell_size = cell_size
      reset_grid
    end

    # Resets the spatial grid
    def reset_grid
      @grid = {}
    end

    # Inserts an object into the spatial grid
    # @param obj [Object] Object with x, y, w, h properties
    def insert(obj)
      cells = get_cells(obj)
      cells.each do |cell_key|
        @grid[cell_key] ||= []
        @grid[cell_key] << obj unless @grid[cell_key].include?(obj)
      end
    end

    # Removes an object from the spatial grid
    # @param obj [Object] Object to remove
    def remove(obj)
      cells = get_cells(obj)
      cells.each do |cell_key|
        @grid[cell_key]&.delete(obj)
      end
    end

    # Gets all objects that could potentially collide with the given object
    # @param obj [Object] Object with x, y, w, h properties
    # @return [Array] Array of objects that share cells with the given object
    def get_nearby(obj)
      cells = get_cells(obj)
      nearby = []
      cells.each do |cell_key|
        nearby.concat(@grid[cell_key]) if @grid[cell_key]
      end
      nearby.uniq.reject { |o| o == obj }
    end

    # Updates an object's position in the grid
    # @param obj [Object] Object to update
    def update(obj)
      remove(obj)
      insert(obj)
    end

    # Rebuilds the entire grid from a list of objects
    # @param objects [Array] Array of objects to populate the grid
    def rebuild(objects)
      reset_grid
      objects.each { |obj| insert(obj) }
    end

    private

    # Gets all cell keys that an object occupies
    # @param obj [Object] Object with x, y, w, h properties
    # @return [Array<String>] Array of cell keys
    def get_cells(obj)
      # Handle both hash-like and object-like access
      x = obj.respond_to?(:x) ? obj.x : obj[:x]
      y = obj.respond_to?(:y) ? obj.y : obj[:y]
      w = obj.respond_to?(:w) ? obj.w : obj[:w]
      h = obj.respond_to?(:h) ? obj.h : obj[:h]

      min_x = (x / @cell_size).floor
      min_y = (y / @cell_size).floor
      max_x = ((x + w) / @cell_size).floor
      max_y = ((y + h) / @cell_size).floor

      cells = []
      (min_x..max_x).each do |cell_x|
        (min_y..max_y).each do |cell_y|
          cells << "#{cell_x},#{cell_y}"
        end
      end
      cells
    end
  end
end
