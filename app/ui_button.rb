# frozen_string_literal: true
module HuskGame
  class UiButton < Zif::UI::TwoStageButton
    attr_accessor :click_center

    def initialize(
      name: Zif.unique_name('ui_button'),
      path_root: nil,
      direction: :north,
      x: 0,
      y: 0,
      click_center: nil,
      &block
    )
      puts "UIBUTTON INIT"
      # super(name, &block)
      super (name)
      @on_mouse_down = ->(_sprite, point) {
        puts "on_mouse_down"
        block&.call(point)
        toggle_pressed
      }

      @w = case direction
           when :north, :south
             184
           when :east, :west
             113
           when :cw, :ccw
             166
           else
             110
           end
      @h = case direction
           when :north, :south
             113
           when :east, :west
             184
           when :cw, :ccw
             166
           else
             110
           end

      @x = x -@w.half
      @y = y - @h.half

      click_center ||= self.center
      @click_center = click_center
      puts "#{name} click_center: #{click_center}"
      @click_distance = 40

      path_root ||= "playercontrols/#{direction.to_s}"

      $services[:sprite_registry].register_basic_sprite(
        "#{path_root}_up",
        width: @w,
        height: @h
      )
      $services[:sprite_registry].alias_sprite(
        "#{path_root}_up",
        "#{direction}_up"
      )
      $services[:sprite_registry].register_basic_sprite(
        "#{path_root}_down",
        width: @w,
        height: @h
      )
      $services[:sprite_registry].alias_sprite(
        "#{path_root}_down",
        "#{direction}_down"
      )

      @normal << $services[:sprite_registry].construct("#{direction}_up")
      @pressed << $services[:sprite_registry].construct("#{direction}_down")

      # This is really important
      # It sets the initial @sprites array from @normal
      unpress
    end

    def absorb_click?
      puts "absorb click: #{name}"
      false
    end
    def clicked?(point, kind = nil)
      puts "clicked #{name}: #{$gtk.args.geometry.distance(point, @click_center) < @click_distance}"
      self if $gtk.args.geometry.distance(point, @click_center) < @click_distance
    end
  end
end