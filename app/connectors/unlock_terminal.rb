module HuskGame
  class UnlockTerminal < Connector

    def self.sprite_details
      @sprite_details ||= $game.services[:sprite_data_loader].load('unlockterminal')
    end

    def initialize(x: 0, y: 0, scale: :large, facing: :south, tolerance: 4, data: 500, data_rate: 2, husk: nil)
      super(x: x, y: y, scale: scale, facing: facing, tolerance: tolerance, data: data, data_rate: data_rate)
      @husk = husk
      @audio_idle = 'sounds/dataterminal_idle.wav'
    end

    def on_data_depleted(collidee)
      @husk.all_unlocked = true if @husk
      play_voiceover "sounds/voice_datacollected.wav"
      @audio_idle = nil
      $gtk.args.audio[@name.to_sym] = nil
    end
  end
end
