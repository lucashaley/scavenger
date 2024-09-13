module Zif
  class Sprite
    attr_accessor :active
    def set_position(x, y)
      @x, @y = x, y
    end

    def perform_tick

    end

    def activate
      puts "#{@name} activated"
      @active = true

      # puts "Did we find? #{$gtk.args.audio.dig(@name.to_sym, :paused)}"
      # if $gtk.args.audio.dig(@name.to_sym, :paused)
      #   $gtk.args.audio[@name.to_sym][:paused] = false
      # end

      $gtk.args.audio[@name.to_sym] = {
        input: @audio_idle,  # file path relative to mygame directory
        gain:    1.0,             # Volume (float value 0.0 to 1.0)
        pitch:   1.0,             # Pitch of the sound (1.0 = original pitch)
        paused:  false,           # Set to true to pause the sound at the current playback position
        looping: true,            # Set to true to loop the sound/music until you stop it
        foobar:  :baz,            # additional keys/values can be safely added to help with context/game logic (ie metadata)
        x: 0.0, y: 0.0, z: 0.0    # Relative position to the listener, x, y, z from -1.0 to 1.0
      } unless @audio_idle.nil?
    end

    def deactivate
      puts "#{@name} deactivated"
      @active = false

      # puts "Did we find? #{$gtk.args.audio.dig(@name.to_sym, :paused)}"
      # if $gtk.args.audio.dig(@name.to_sym, :paused)
      #   $gtk.args.audio[@name.to_sym][:paused] = true
      # end

      $gtk.args.audio[@name.to_sym] = nil
    end
  end

  class CompoundSprite
    def center_sprites
      sprites.each do |s|
        s.x = (s.w - @w).half
        s.y = (s.h - @h).half
      end
    end
  end
end