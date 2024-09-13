module Spatializeable
  def spatialize(audio_ref)
    return if audio_ref.nil?

    pan = (self.rect.x - $game.scene.ship.rect.x) * 0.0015625 # 1/640
    $gtk.args.audio[audio_ref][:x] = pan
    $gtk.args.audio[audio_ref][:gain] = 1 - pan.abs
  end
end