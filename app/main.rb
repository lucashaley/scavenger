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
