module HuskEngine
  module Soundable
    SOUND_COOLDOWN_FRAMES = 10

    def play_once(file, gain=nil)
      @sound_last_played_at ||= {}
      now = Kernel.tick_count
      last = @sound_last_played_at[file] || -SOUND_COOLDOWN_FRAMES
      return if (now - last) < SOUND_COOLDOWN_FRAMES

      @sound_last_played_at[file] = now
      unless gain
        $gtk.args.outputs.sounds << file
      else
        $gtk.args.audio[@name] = {
          input: file,
          gain: gain,
          looping: false
        }
      end
    end

    def play_voiceover(file)
      $gtk.args.audio[:voiceover] = {
        input: file
      }
    end
  end
end