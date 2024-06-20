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
require 'app/environment_scene.rb'

def tick args
  if args.tick_count == 2
    args.gtk.set_window_scale 0.75
    args.gtk.set_window_fullscreen false
    $game = BaseGame.new
    $game.scene.prepare_scene
  end
  $game&.perform_tick
end

module Easing
  def self.ease_in_and_out_cubic x
    return x < 0.5 ? 4 * x * x * x : 1 - ((-2 * x + 2) ** 3) / 2;
  end
end
