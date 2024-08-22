module Scaleable
  attr_accessor :scale, :sprite_scale_hash, :current_sprite_hash
  attr_accessor :scale_ratio

  def set_scale scale=:large
    puts "Scaleable set_scale: #{scale}"
    @scale = scale
    @scale_ratio ||= 1 # was used for non-square sprites, blechh

    @h = $SPRITE_SCALES[scale]
    @w = $SPRITE_SCALES[scale] * @scale_ratio

    @current_sprite_hash = @sprite_scale_hash[@scale]

    refresh_sprites
  end

  def refresh_sprites
    @sprites = @current_sprite_hash.values
    view_actual_size!
  end

  def collate_sprites path
    @sprite_scale_hash ||= Hash.new

    sprite_directory = $gtk.args.gtk.stat_file "sprites/#{path}"
    puts "sprite_directory: #{sprite_directory}"
    puts "ERROR: no sprite directory" if sprite_directory.nil?

    sprite_files = $gtk.args.gtk.list_files sprite_directory[:path]
    puts "sprite_files: #{sprite_files}\n"
    puts "ERROR: no sprite files" if sprite_files.empty?

    sprite_files.each do |file|
      name_array = file.split('.').first.split('_')
      name_hash = {
        full: file,
        type: name_array.first.to_sym,
        section: name_array[1].to_sym,
        scale: name_array.last.to_sym
      }

      @sprite_scale_hash[name_hash[:scale]] ||= Hash.new
      @sprite_scale_hash[name_hash[:scale]].merge!({name_hash[:section] => Zif::Sprite.new.tap do |s|
        s.name = "#{name_hash[:type]}_#{name_hash[:section]}_#{name_hash[:scale]}"
        s.h = $SPRITE_SCALES[name_hash[:scale]]
        s.w = $SPRITE_SCALES[name_hash[:scale]]
        # s.h = sprite_scales(name_hash[:scale])
        # s.w = sprite_scales(name_hash[:scale])
        s.path = "sprites/#{path}/#{file}"
      end
      })
    end
  end
end
