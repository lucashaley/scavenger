# frozen_string_literal: true
module HuskGame
  class UiButton < Zif::UI::TwoStageButton

    def initialize(
      name: Zif.unique_name('ui_button'),
      path_root: nil,
      x: 40,
      y: 120,
      &block
    )
      puts "UIBUTTON INIT"
      super(name)

      @x = x
      @y = y
      @w = 184
      @h = 113

      $services[:sprite_registry].register_basic_sprite(
        "#{path_root}_up",
        width: 184,
        height: 113
      )
      $services[:sprite_registry].alias_sprite(
        "#{path_root}_up",
        :north_up
      )
      $services[:sprite_registry].register_basic_sprite(
        "#{path_root}_down",
        width: 184,
        height: 113
      )
      $services[:sprite_registry].alias_sprite(
        "#{path_root}_down",
        :north_down
      )

      puts "#{path_root}_up"

      @normal << $services[:sprite_registry].construct("#{path_root}_up")
      @pressed << $services[:sprite_registry].construct("#{path_root}_down")

      @on_mouse_down = lambda { |_sprite, point|
        puts "point: #{point}"
        block&.call(point)
        toggle_pressed if @is_pressed
      }

      # b.normal << $services[:sprite_registry].construct(:north_up)
      # b.pressed << $services[:sprite_registry].construct(:north_down)
      # b.w = 184
      # b.h = 113
      # b.x = 40
      # b.y = 200
      # b.unpress
    end
  end
end