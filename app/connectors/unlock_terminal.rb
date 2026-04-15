module HuskGame
  class UnlockTerminal < Connector

    sprite_data 'unlockterminal'

    def initialize(x: 0, y: 0, scale: :large, facing: :south, tolerance: 4, data: 500, data_rate: 2, husk: nil)
      super(x: x, y: y, scale: scale, facing: facing, tolerance: tolerance, data: data, data_rate: data_rate)
      @husk = husk
      @audio_idle = HuskGame::AssetPaths::Audio::DATA_TERMINAL_IDLE
    end

    def on_data_depleted(collidee)
      @husk.all_unlocked = true if @husk
      play_voiceover HuskGame::AssetPaths::Audio::VOICE_DOORS_UNLOCKED
      @audio_idle = nil
      $gtk.args.audio[@name.to_sym] = nil
    end
  end
end
