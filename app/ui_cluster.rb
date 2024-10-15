# frozen_string_literal: true
module HuskGame
  class UiCluster
    include Zif::UI

    attr_accessor :x, :y
    attr_accessor :buttons
    attr_accessor :button_north, :button_east, :button_west, :button_south

    def initialize(
      x: 240,
      y: 320
    )
      puts "UI CLUSTER INIT"

      @x = x
      @y = y

      @buttons = []

      directional_padding = 118
      rotational_padding = 110

      @button_north = UiButton.new(
        name: 'ui_button_north',
        direction: :north,
        y: directional_padding
      ) {
        $gtk.notify! ("button pressed!")
      }
      @buttons << @button_north

      @button_south = UiButton.new(
        name: 'ui_button_south',
        direction: :south,
        y: -directional_padding
      ) {
        $gtk.notify! ("button pressed!")
      }
      @buttons << @button_south

      @button_east = UiButton.new(
        name: 'ui_button_east',
        direction: :east,
        x: directional_padding
      ) {
        $gtk.notify! ("East button pressed!")
      }
      @buttons << @button_east

      @button_west = UiButton.new(
        name: 'ui_button_west',
        direction: :west,
        x: -directional_padding
      ) {
        $gtk.notify! ("West button pressed!")
      }
      @buttons << @button_west

      @button_emp = UiButton.new(
        name: 'ui_button_emp',
        direction: :emp
      ) {
        $gtk.notify! ("EMP button pressed!")
      }
      @buttons << @button_emp

      @button_cw = UiButton.new(
        name: 'ui_button_cw',
        direction: :cw,
        x: rotational_padding,
        y: -rotational_padding,
        click_center: [-140, 140]
      ) {
        $gtk.notify! ("CW button pressed!")
      }
      @buttons << @button_cw

      @button_ccw = UiButton.new(
        name: 'ui_button_ccw',
        direction: :ccw,
        x: -rotational_padding,
        y: rotational_padding,
        click_center: [140, -140]
      ) {
        $gtk.notify! ("CCW button pressed!")
      }
      @buttons << @button_ccw

      # Make all the positions absolute instead of relative
      # And register with Clickables
      @buttons.map do |b|
        b.x += @x
        b.y += @y
        b.click_center.x += @x
        b.click_center.y += @y
        $game.services[:input_service].register_clickable b

        puts "#{b.name} click_center: #{b.click_center}"
      end
    end

    def render
      # puts "UiCluster Render: #{@buttons}"
      @buttons
    end
  end
end