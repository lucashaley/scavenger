module HuskEngine
  module Soundable
    def play_once(file, gain=nil)
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
      puts "play_voiceover #{file}"
      $gtk.args.audio[:voiceover] = {
        input: file
      }
    end
  end
end