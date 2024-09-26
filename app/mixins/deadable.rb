module HuskEngine
  module Deadable
    @dead = false

    def is_dead?
      @dead
    end

    def kill
      puts "Killing: #{@name}"
      $gtk.args.audio[@name.to_sym] = nil
      @dead = true
      @active = false
      hide
    end
  end
end