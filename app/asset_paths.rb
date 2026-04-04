module HuskGame
  module AssetPaths
    # Audio paths
    module Audio
      # Music
      MUSIC_INTRO = "music/Lucas_HuskGame_intro.wav".freeze
      MUSIC_108 = "music/Lucas_HuskGame_108.wav".freeze
      MUSIC_108_DNB = "music/Lucas_HuskGame_108_DnB.wav".freeze
      MUSIC_118 = "music/Lucas_HuskGame_118.wav".freeze
      MUSIC_118_DNB = "music/Lucas_HuskGame_118_DnB.wav".freeze
      MUSIC_128 = "music/Lucas_HuskGame_128.wav".freeze
      MUSIC_128_DNB = "music/Lucas_HuskGame_128_DnB.wav".freeze

      # Sound effects
      EMP_BLAST = "sounds/emp_blast.wav".freeze
      THUMP = "sounds/thump.wav".freeze
      MINE_IDLE = "sounds/mine_idle.wav".freeze

      # Voice overs
      VOICE_DRONE_DAMAGED = "sounds/voice_dronedamaged.wav".freeze
      VOICE_DATA_CORE_COLLECTED = "sounds/voice_datacorecollected.wav".freeze
      VOICE_DATA_CORE_OVERLOADED = "sounds/voice_datacoreoverloaded.wav".freeze
      VOICE_WARNING = "sounds/voice_warning.wav".freeze
      VOICE_WARNING_HUSK_INTEGRITY = "sounds/voice_warninghuskstructuralintegrityisfailing.wav".freeze
      VOICE_RETURN_TO_BREACH = "sounds/voice_returntobreach.wav".freeze
    end

    # Sprite paths
    module Sprites
      # Ship sprites
      SHIP_BASE_PATH = "sprites/ship".freeze

      # Toggle to use rotated (single-source) thrust sprites
      @use_rotated_thrust = false

      def self.use_rotated_thrust?
        @use_rotated_thrust
      end

      def self.use_rotated_thrust=(val)
        @use_rotated_thrust = val
      end

      # Helper method to generate ship thrust sprite paths
      def self.ship_thrust_sprite(direction, scale, power = nil)
        prefix = @use_rotated_thrust ? "ship_thrust_rot_" : "ship_thrust"
        base = "#{SHIP_BASE_PATH}/#{prefix}#{direction}_#{scale}"
        power ? "#{base}_power_0#{power}.png" : "#{base}.png"
      end

      # UI sprites
      UI_MAIN = "sprites/1bit_ui.png".freeze
      UI_SHIP_HEALTH = "sprites/ui_ship_health.png".freeze
      UI_SHIP_HEALTH_WEST = "sprites/ui_ship_health_west.png".freeze
      UI_SHIP_HEALTH_EAST = "sprites/ui_ship_health_east.png".freeze
      UI_SHIP_HEALTH_NORTH = "sprites/ui_ship_health_north.png".freeze
      UI_SHIP_HEALTH_SOUTH = "sprites/ui_ship_health_south.png".freeze

      # Overlay sprites
      OVERLAY_01_LARGE = "sprites/overlay01/overlay01_main_large.png".freeze

      # Floor sprites
      def self.floor_sprite(scale, variant)
        "sprites/floor_#{scale}_0#{variant}.png"
      end

      # Viewport mask
      VIEWPORT_MASK = "sprites/viewport_mask.png".freeze
    end

    # Font paths
    module Fonts
      KENVECTOR_FUTURE = "sprites/kenney-uipack-space/Fonts/kenvector_future.ttf".freeze
    end
  end
end
