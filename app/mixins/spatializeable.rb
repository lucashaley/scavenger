module HuskEngine
  module Spatializeable
    def spatialize(audio_ref)
      raise ArgumentError if audio_ref.nil?
      raise NameError if $gtk.args.audio[audio_ref].nil?
      return if audio_ref.nil? || $gtk.args.audio[audio_ref].nil?

      # pan = (self.rect.x - $game.scene.ship.rect.x) * 0.0015625 # 1/640
      pan = (self.rect.x - $gtk.args.state.ship.rect.x) * 0.0015625
      $gtk.args.audio[audio_ref][:x] = pan
      $gtk.args.audio[audio_ref][:gain] = 1 - pan.abs
    end
  end
end