# Require for library
require 'lib/require.rb'

# Require for app-specifics
require 'app/require.rb'

# Scenes
require 'app/base_game.rb'
# require 'app/movement_scene.rb'
# require 'app/walls_scene.rb'
# require 'app/ui_scene.rb'
# require 'app/door_scene.rb'
# require 'app/class_scene.rb'
# require 'app/pickup_scene.rb'
# require 'app/animation_scene.rb'
# require 'app/environment_scene.rb'
require 'app/room_scene.rb'

def tick args
  # $gtk.trace_nil_punning! # Not sure what this does
  if args.tick_count == 2
    args.gtk.set_window_scale 0.75
    args.gtk.set_window_fullscreen false
    $game = BaseGame.new
    $game.scene.prepare_scene

    # Delete this when done with room switching
    args.state.rooms ||= []

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
