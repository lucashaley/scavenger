# Require for library
require 'lib/require.rb'

# Require for app-specifics
require 'app/require.rb'

# Scenes
require 'app/base_game.rb'

require 'app/scenes/splash_scene.rb'
require 'app/scenes/room_scene.rb'
require 'app/scenes/game_over_scene'
require 'app/scenes/game_complete_scene'
require 'app/scenes/menu_main_scene'

# Amir's hack for audio crashes
class AudioHash < Hash
  # alias []= so we can redefine it
  alias_method :__original_indexor_set__, :[]= if !AudioHash.instance_methods.include?(:__original_indexor_set__)

  def []= key, value
    # check to see if there's already an entry
    current = self[key]

    if current
      # if there is, then set the gain to zero and requeue it so that C can handle clean up
      current.gain = 0
      __original_indexor_set__ GTK.create_uuid, current
    end

    # set the key to the new object
    __original_indexor_set__ key, value
  end
end

def tick args
  # $gtk.trace_nil_punning! # Not sure what this does

  if args.tick_count == 2
    args.gtk.set_window_scale 1
    args.gtk.set_window_fullscreen false
    $game = HuskGame::BaseGame.new
    $game.scene.prepare_scene

    # Shader stuff
    # args.outputs.shader_path ||= "shaders/crt.glsl"
    # args.outputs.shader_tex1 = :tiles
  end
  $game&.perform_tick
end

module Easing
  def self.ease_in_and_out_cubic x
    return x < 0.5 ? 4 * x * x * x : 1 - ((-2 * x + 2) ** 3) / 2;
  end
end
