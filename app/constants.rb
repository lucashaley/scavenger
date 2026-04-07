module HuskGame
  module Constants
    # Screen dimensions
    SCREEN_WIDTH = 720
    SCREEN_HEIGHT = 1280

    # Viewscreen dimensions
    VIEWSCREEN_BORDER = 40
    VIEWSCREEN_SIZE = 640
    VIEWSCREEN_OFFSET_X = 40
    VIEWSCREEN_OFFSET_Y = 560

    # Viewscreen bounds
    VIEWSCREEN = {
      top: SCREEN_HEIGHT - 80,
      right: SCREEN_WIDTH - VIEWSCREEN_BORDER,
      bottom: SCREEN_HEIGHT - 80 - VIEWSCREEN_SIZE,
      left: VIEWSCREEN_BORDER
    }.freeze

    # Sprite scales (pixels per unit)
    SPRITE_SCALES = {
      large: 64,
      medium: 40,
      small: 32,
      tiny: 16
    }.freeze

    # UI styles
    LABEL_STYLE = {
      r: 0,
      g: 0,
      b: 255,
      size_px: 14
    }.freeze

    BACKGROUND_STYLE = {
      r: 0,
      g: 255,
      b: 0,
      a: 128,
      path: :solid
    }.freeze

    # Colors
    COLOR_DARK_GREEN = { r: 54, g: 63, b: 54 }.freeze
    COLOR_LIGHT_GREEN = { r: 198, g: 207, b: 186 }.freeze

    # Default bounce scales per sprite size
    BOUNCE_SCALES = {
      large: 0.8,
      medium: 0.4,
      small: 0.1,
      tiny: 0.05
    }.freeze

    # UI layout
    PROGRESS_BAR_WIDTH = 440
    PROGRESS_BAR_Y_HUSK = 1220
    PROGRESS_BAR_Y_DATA = 1200

    # Physics — shared across multiple entity types
    HAZARD_BOUNCE = 0.9
    RELATIVE_SPEED_MULTIPLIER = 0.05
    THRUST_MAX_POWER_LEVEL = 3

    # EMP system defaults (overridden per-entity in initialize_empable)
    EMP_DEFAULT_LOW_THRESHOLD = 120
    EMP_DEFAULT_MEDIUM_THRESHOLD = 360

    # Audio
    DEFAULT_MUSIC_VOLUME = 0.3

    # Husk types for selection scene
    # chaos: controls door generation (lower = more doors = bigger husk)
    # threat: controls entity danger (higher = more agents/hazards)
    HUSK_TYPES = [
      { name: 'STABLE',    chaos: 3, threat: 0, description: 'Minimal interference. A clean run.' },
      { name: 'WEATHERED', chaos: 2, threat: 1, description: 'Some resistance. Stay alert.' },
      { name: 'CORRUPTED', chaos: 1, threat: 2, description: 'Heavy corruption. Dangerous.' },
      { name: 'VOLATILE',  chaos: 0, threat: 3, description: 'Maximum threat. Good luck.' }
    ].freeze

    # Blend modes
    BLENDMODE = {
      none: 0,
      alpha: 1,
      add: 2,
      mod: 3,
      multiply: 4
    }.freeze
  end
end
