# frozen_string_literal: true
module HuskGame
  class UiCluster
    include Zif::UI

    attr_accessor :x, :y
    attr_accessor :buttons
    attr_accessor :button_north, :button_east, :button_west, :button_south

    def initialize(
      x: 40,
      y: 120
    )
      puts "UI CLUSTER INIT"

      @x = x
      @y = y

      @buttons = []

      $services[:sprite_registry].register_basic_sprite(
        "playercontrols/north_up",
        width: 184,
        height: 113
      )
      $services[:sprite_registry].alias_sprite(
        "playercontrols/north_up",
        :north_up
      )
      $services[:sprite_registry].register_basic_sprite(
        "playercontrols/north_down",
        width: 184,
        height: 113
      )
      $services[:sprite_registry].alias_sprite(
        "playercontrols/north_down",
        :north_down
      )
      @button_north = UiButton.new(name: 'ui_button_north', path_root: "playercontrols/north")
      puts "button_north: #{@button_north}"

      @buttons << @button_north

      # Register all buttons as Clickables
      @buttons.each { |b| $game.services[:input_service].register_clickable b }
    end

    def render
      @buttons
    end
  end
end