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
