module Zif
  class Sprite
    attr_accessor :active

    def class_name
      self.class.name.split("::").last.downcase
    end

    def set_position(x, y)
      @x, @y = x, y
    end

    def right_side
      @x + @w
    end

    def top_side
      @y + @h
    end

    def left_side
      @x
    end

    def bottom_side
      @y
    end

    def active?
      @active
    end

    def activate
      # puts "#{@name} activated"
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
      # puts "#{@name} deactivated"
      @active = false

      # puts "Did we find? #{$gtk.args.audio.dig(@name.to_sym, :paused)}"
      # if $gtk.args.audio.dig(@name.to_sym, :paused)
      #   $gtk.args.audio[@name.to_sym][:paused] = true
      # end

      $gtk.args.audio[@name.to_sym] = nil
    end

    # def to_s
    #   "name: #{@name}\n"
    #   "xy: #{self.xy}"
    # end
  end

  class CompoundSprite
    def center_sprites
      # puts "center_sprites"
      sprites.each do |s|
        s.x = (@w - s.w).half
        s.y = (@h - s.h).half
      end
    end

    def rotate_sprites facing
      case facing
      when Symbol
        sprites.each do |s|
          s.angle = case facing
                    when :south
                      0
                    when :east
                      90
                    when :north
                      180
                    when :west
                      270
                    end
        end
      when Numeric
        sprites.each do |s|
          s.angle = facing
        end
      end
      # puts "rotate sprites: #{facing}"
      # sprites.each do |s|
      #   s.angle = case facing
      #             when :south
      #               0
      #             when :east
      #               90
      #             when :north
      #               180
      #             when :west
      #               270
      #             end
      # end
      center_sprites # just in case
    end

    # def to_s
    #   puts %{
    #     Name: #{@name}
    #     Sprite count: #{@sprites.count}
    #     Sprite hash: #{@sprite_scale_hash}
    #   }
    # end
  end
end