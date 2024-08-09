# Should this just be a part of Scaleable?

module Collateable
  # def collate_sprites path
  #   sprite_directory = $gtk.args.gtk.stat_file "sprites/boost"
  #   # puts "sprite_directory: #{sprite_directory}"
  #   sprite_files = $gtk.args.gtk.list_files sprite_directory[:path]
  #   puts "sprite_files: #{sprite_files}\n"
  #   sprite_files.each do |file|
  #     name_array = file.split('.').first.split('_')
  #     name_hash = {
  #       full: file,
  #       type: name_array.first.to_sym,
  #       section: name_array[1].to_sym,
  #       scale: name_array.last.to_sym
  #     }
  #
  #     @sprite_scale_hash[name_hash[:scale]] ||= Hash.new
  #     @sprite_scale_hash[name_hash[:scale]].merge!({name_hash[:section] => Zif::Sprite.new.tap do |s|
  #     # @sprite_scale_hash[name_hash[:scale].to_sym][name_hash[:section].to_sym] = Zif::Sprite.new.tap do |s|
  #     # @sprite_scale_hash[name_array.last.to_sym] = {name_array[1].to_sym => Zif::Sprite.new.tap do |s|
  #       s.h = SPRITE_SCALES[name_hash[:scale]]
  #       s.w = SPRITE_SCALES[name_hash[:scale]]
  #       s.path = "sprites/boost/#{file}"
  #     end
  #     })
  # end
end
