module Soundable
  def play_once file
    $gtk.args.outputs.sounds << file
  end
end
