module HuskEngine
  module Scaleable
    include Zif::Traceable

    attr_accessor :scale, :sprite_scale_hash, :current_sprite_hash
    attr_accessor :scale_ratio

    def set_scale scale=:large
      # puts "Scaleable set_scale: #{scale}"
      @scale = scale
      @scale_ratio ||= 1 # was used for non-square sprites, blechh

      # @h = $SPRITE_SCALES[scale]
      # @w = $SPRITE_SCALES[scale] * @scale_ratio

      # puts "Setting Scale: #{self.class::SPRITE_DETAILS[:scales][scale][:h]}, #{self.class::SPRITE_DETAILS[:scales][scale][:v]}"

      @h = self.class::SPRITE_DETAILS[:scales][scale][:h]
      @w = self.class::SPRITE_DETAILS[:scales][scale][:w]

      @current_sprite_hash = @sprite_scale_hash[@scale]

      refresh_sprites
    end

    def refresh_sprites
      raise StandardError, "@current_sprite_hash doesn't exist" if @current_sprite_hash.nil?
      begin
        @sprites = @current_sprite_hash.values.sort_by(&:z_index)
        center_sprites

        # What is this doing here
        # TODO: put this somewhere useful
        if self.is_a? Shadowable
          # we need to set the size of the shadow to be slightly larger than the current size
          # @class_name = self.class.name.split("::").last.downcase
          # puts @class_name
          # puts "#{@class_name}_shadow_#{@scale}"
          # puts @sprites
          @sprites.find { |s| s.name == "#{class_name}_shadow_#{@scale}" }.assign(
            {
              h: self.class::SPRITE_DETAILS[:scales][scale][:h],
              w: self.class::SPRITE_DETAILS[:scales][scale][:w]
            }
          )
        end

        view_actual_size!
      rescue => e
        puts "There was an error in refreshing the sprites. #{e.message}"
      end
    end

    def register_sprites_new
      @tracer_service_name = :tracer
      # mark_and_print("register_sprites")
      return unless self.class.const_defined?(:SPRITE_DETAILS)

      sprite_base_name = self.class::SPRITE_DETAILS[:name]
      # sprite_base_name = class_name
      # puts sprite_base_name
      sprite_directory = $gtk.args.gtk.stat_file "sprites/#{sprite_base_name}"
      sprite_files = $gtk.args.gtk.list_files sprite_directory[:path]

      raise StandardError, "register_sprites_new is broken" if \
        sprite_base_name.nil? || sprite_directory.nil? || sprite_files.nil?

      sprite_files.each do |file|
        name_array = file.split('.').first.split('_')
        next if name_array.length > 3 # We don't need to register animations as yet
        sprite_name = name_array.join("_")
        sprite_path = "#{sprite_base_name}/#{sprite_name}"

        # puts "Registering: #{sprite_name}, #{sprite_path}"

        # mark_and_print("Already registered #{sprite_path}: #{$services[:sprite_registry].sprite_registered? sprite_path}")
        next if $services[:sprite_registry].sprite_registered? sprite_path
        image_size = $gtk.args.gtk.calcspritebox("sprites/#{sprite_path}.png")

        $services[:sprite_registry].register_basic_sprite(
          sprite_path,
          width: image_size[0],
          height: image_size[1]
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
      raise ArgumentError "No scale provided" if scale.nil?

      @scale = scale
      @scale_ratio ||= 1 # was used for non-square sprites, blechh

      # @h = $SPRITE_SCALES[scale]
      # @w = $SPRITE_SCALES[scale] * @scale_ratio

      @sprite_scale_hash ||= Hash.new

      # Work through the data, starting with each layer
      details = self.class::SPRITE_DETAILS
      # puts "details: #{details}"
      new_sprite = nil

      details[:layers].each do |layer|
        # puts "Creating #{layer[:name]}"
        details[:scales].each_key do |scale_k|
          # puts "Create #{layer[:name]}: #{scale.to_s}"
          # Create the scale hash if it doesn't exist already
          # This is weird, because in our naming convention
          # the layer comes first, but in the hash
          # the scale comes first.
          # puts "scales: #{scale_k}: #{scale_v}"

          @sprite_scale_hash[scale_k] ||= Hash.new

          # Create the sprite
          new_name = "#{details[:name]}_#{layer[:name]}_#{scale_k}"

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
              animation_name = "#{details[:name]}_#{layer[:name]}_#{scale_k}_#{animation[:name]}"
              animation[:frames].each do |frame|
                paths << ["#{details[:name]}/#{animation_name}_0#{frame}", animation[:hold]]
              end
              # puts paths
              # puts "\n\nCreate #{layer[:name]}: #{scale.to_s}: #{animation.name}"
              new_sprite.new_basic_animation(
                named: animation[:name].to_sym,
                paths_and_durations: paths,
                repeat: animation[:repeat]
              ) { self.complete_animation(animation[:name].to_sym) if self.respond_to? (:complete_animation) }
            end
          end

          # This works, but it's not rotated to facing
          @sprite_scale_hash[scale_k][layer[:name].to_sym] = new_sprite
          # The rotation is handled in the object itself?
        end
      end

      raise StandardError, "@sprite_scale_hash[@scale] not found: #{new_sprite.name}, #{@scale}\n#{@sprite_scale_hash}" \
        if @sprite_scale_hash[@scale].nil?
      @current_sprite_hash = @sprite_scale_hash[@scale]

      set_scale @scale
      refresh_sprites
    end
  end
end