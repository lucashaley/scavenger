module Scaleable
  include Zif::Traceable

  attr_accessor :scale, :sprite_scale_hash, :current_sprite_hash
  attr_accessor :scale_ratio

  def set_scale scale=:large
    # puts "Scaleable set_scale: #{scale}"
    @scale = scale
    @scale_ratio ||= 1 # was used for non-square sprites, blechh

    @h = $SPRITE_SCALES[scale]
    @w = $SPRITE_SCALES[scale] * @scale_ratio

    @current_sprite_hash = @sprite_scale_hash[@scale]
    # puts @current_sprite_hash

    refresh_sprites
  end

  def refresh_sprites
    @sprites = @current_sprite_hash.values.sort_by(&:z_index)
    center_sprites
    view_actual_size!
  end

  # The naming convention so far is:
  # ~thing_layer_scale~
  # or
  # ~thing_layer_scale_animation_frame~
  # So we need to count how many segments there are, and change the output
  # based on that?
  # def collate_sprites path
  #   @tracer_service_name = :tracer
  #   mark_and_print("collate_sprites")
  #   @sprite_scale_hash ||= Hash.new
  #
  #   sprite_directory = $gtk.args.gtk.stat_file "sprites/#{path}"
  #   sprite_files = $gtk.args.gtk.list_files sprite_directory[:path]
  #
  #   sprite_files.each do |file|
  #     name_array = file.split('.').first.split('_') # Remove the .extension
  #     # puts "name_array: #{name_array}"
  #     next if name_array.length > 3 # we don't want animation files here
  #     name_hash = {
  #       full: file,
  #       type: name_array.first.to_sym,
  #       layer: name_array[1].to_sym,
  #       scale: name_array.last.to_sym
  #     }
  #
  #     @sprite_scale_hash[name_hash[:scale]] ||= Hash.new
  #     @sprite_scale_hash[name_hash[:scale]].merge!({name_hash[:layer] => Zif::Sprite.new.tap do |s|
  #       s.name = "#{name_hash[:type]}_#{name_hash[:layer]}_#{name_hash[:scale]}"
  #       s.h = $SPRITE_SCALES[name_hash[:scale]]
  #       s.w = $SPRITE_SCALES[name_hash[:scale]]
  #       # s.h = sprite_scales(name_hash[:scale])
  #       # s.w = sprite_scales(name_hash[:scale])
  #       s.path = "sprites/#{path}/#{file}"
  #     end
  #     })
  #
  #     new_name = "#{name_hash[:type]}_#{name_hash[:layer]}_#{name_hash[:scale]}"
  #     # puts "new_name: #{new_name}"
  #     new_sprite = Zif::Sprite.new(new_name).tap do |s|
  #       s.h = $SPRITE_SCALES[name_hash[:scale]]
  #       s.w = $SPRITE_SCALES[name_hash[:scale]]
  #       s.path = "sprites/#{path}/#{file}"
  #     end
  #   end
  # end

  def register_sprites_new
    @tracer_service_name = :tracer
    # mark_and_print("register_sprites")
    return unless self.class.const_defined?(:SPRITE_DETAILS)

    sprite_base_name = self.class::SPRITE_DETAILS[:name]
    sprite_directory = $gtk.args.gtk.stat_file "sprites/#{sprite_base_name}"
    sprite_files = $gtk.args.gtk.list_files sprite_directory[:path]

    sprite_files.each do |file|
      name_array = file.split('.').first.split('_')
      next if name_array.length > 3 # We don't need to register animations as yet
      sprite_name = name_array.join("_")
      sprite_path = "#{sprite_base_name}/#{sprite_name}"

      # mark_and_print("Already registered #{sprite_path}: #{$services[:sprite_registry].sprite_registered? sprite_path}")
      next if $services[:sprite_registry].sprite_registered? sprite_path

      # data = IO.binread("sprites/#{sprite_path}", 100) # read first 100 bytes
      # puts "sprites/#{sprite_path}"

      # APPARENTLY THIS IS NOT NECESSARY
      # BECAUSE DR SUPPLIES THIS ALREADY
      # gtk.calcspritebox

      file_data = $gtk.args.gtk.read_file("sprites/#{sprite_path}.png")
      # puts file_data

      if file_data[0, 8] == [137, 80, 78, 71, 13, 10, 26, 10].pack("C*")
        # file has a PNG file signature, let's get the image header chunk

        length, chunk_type = file_data[8, 8].unpack("l>a4")

        raise "unknown format, expecting image header" unless chunk_type == "IHDR"

        chunk_data = file_data[16, length].unpack("l>l>CCCCC")
        width              = chunk_data[0]
        height             = chunk_data[1]
        bit_depth          = chunk_data[2]
        color_type         = chunk_data[3]
        compression_method = chunk_data[4]
        filter_method      = chunk_data[5]
        interlace_method   = chunk_data[6]

        # puts "image size: #{width}x#{height}"
      else
        # handle other formats
        mark_and_print "PNG PARSE BARF"
      end

      # puts "image size: #{width}x#{height}"

      $services[:sprite_registry].register_basic_sprite(
        sprite_path,
        width: width,
        height: height
      )
      $services[:sprite_registry].alias_sprite(
        sprite_path,
        sprite_name.to_sym
      )
    end
  end

  def initialize_scaleable scale
    @tracer_service_name = :tracer
    # mark_and_print("initialize_scaleable")
    # Get out if we're using the old, undefined classes
    return unless self.class.const_defined?(:SPRITE_DETAILS)

    @scale = scale
    @scale_ratio ||= 1 # was used for non-square sprites, blechh

    @h = $SPRITE_SCALES[scale]
    @w = $SPRITE_SCALES[scale] * @scale_ratio

    @sprite_scale_hash ||= Hash.new

    # Work through the data, starting with each layer
    details = self.class::SPRITE_DETAILS
    new_sprite = nil

    details[:layers].each do |layer|
      # puts "Creating #{layer[:name]}"
      details[:scales].each do |scale|
        # puts "Create #{layer[:name]}: #{scale.to_s}"
        # Create the scale hash if it doesn't exist already
        # This is weird, because in our naming convention
        # the layer comes first, but in the hash
        # the scale comes first.

        @sprite_scale_hash[scale] ||= Hash.new

        # Create the sprite
        new_name = "#{details[:name]}_#{layer[:name]}_#{scale}"

        # The dimensions of the sprite is defined in the ~register_sprites~ method
        unless $services[:sprite_registry].sprite_registered? new_name.to_sym
          raise ArgumentError, "Invalid sprite: #{new_name}"
        end
        new_sprite = $services[:sprite_registry].construct(new_name.to_sym).tap do |s|
          s.name = new_name
          # This is where we can adjust the position of the sprite
          # so that it's relatively correct
          # puts "\n\nZ: #{layer[:z]}\n\n"
          s.blendmode_enum = layer[:blendmode_enum]
          s.z_index = layer[:z]
        end

        # Then add the animations
        unless layer[:animations].nil?
          # register the sprite
          $game.services.named(:action_service).register_actionable(new_sprite)
          layer[:animations].each do |animation|
            # create the suffixes
            paths = []
            animation_name = "#{details[:name]}_#{layer[:name]}_#{scale}_#{animation[:name]}"
            animation[:frames].each do |frame|
              paths << ["#{details[:name]}/#{animation_name}_0#{frame}", animation[:hold]]
            end
            # puts paths
            # puts "\n\nCreate #{layer[:name]}: #{scale.to_s}: #{animation.name}"
            new_sprite.new_basic_animation(
              named: animation[:name].to_sym,
              paths_and_durations: paths,
              repeat: animation[:repeat]
            )
          end
        end

        # This works, but it's not rotated to facing
        @sprite_scale_hash[scale][layer[:name].to_sym] = new_sprite
        # The rotation is handled in the object itself?
      end
    end

    @current_sprite_hash = @sprite_scale_hash[@scale]

    refresh_sprites
  end
end
