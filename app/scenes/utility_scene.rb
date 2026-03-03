# frozen_string_literal: true
module HuskEngine
  class UtilityScene < Zif::Scene
    include Zif::Traceable

    TITLE_FONT = 'fonts/TAYRosemary.otf'.freeze

    attr :render_layers, :name, :fader

    def initialize
      @tracer_service_name = :tracer

      @next_scene = nil

      @started = false
      @ready = false

      # @fader
      @render_layers = []
      @scene_labels = []
    end

    def prepare_scene
      mark_and_print "prepare_scene"

      @fader = Zif::Sprite.new.tap do |f|
        f.x = 0
        f.y = 0
        f.w = 720
        f.h = 1280
        f.path = :solid
        f.r = 0
        f.g = 0
        f.b = 0
        f.a = 255
      end
      $game.services[:action_service].register_actionable(@fader)
      $gtk.args.outputs.static_sprites << @fader
    end

    def unload_scene
      mark_and_print "unload_scene"
      $game.services[:action_service].reset_actionables
      $game.services[:input_service].reset
      $gtk.args.outputs.static_sprites.clear
      $gtk.args.outputs.static_labels.clear
      $gtk.args.outputs.sprites.clear
    end

    def perform_tick
      # mark_and_print "perform_tick"
      enter_scene unless @started

      $gtk.args.outputs.sprites << @render_layers unless @render_layers.empty?

      if @ready
        @scene_labels.each { |l| $gtk.args.outputs.labels << l } unless @scene_labels.empty?
      end

      $gtk.args.outputs.sprites << @fader

      return @next_scene
    end

    def enter_scene
      mark_and_print "enter_scene"
      @fader.run_action(
        @fader.new_action({a: 0}, duration: 20.frames, easing: :smooth_step3) do
          mark_and_print "Ready"
          @ready = true
        end
      )
      @started = true
    end

    def exit_scene up_next
      mark_and_print "exit_scene to #{up_next.to_s}"
      raise StandardError if up_next.nil?

      @fader.run_action(
        @fader.new_action({a: 255}, duration: 20.frames, easing: :smooth_step3) do
          # $gtk.args.audio[:splash_music] = nil
          # @next_scene = :room
          @next_scene = up_next
        end
      )
    end

    def blurred_label(x, y, text, size, offset)
      base = { text: text, size_enum: size, font: TITLE_FONT, r: 176, g: 191, b: 170 }
      shadows = [
        { x: x,          y: y + offset },
        { x: x,          y: y - offset },
        { x: x - offset, y: y },
        { x: x + offset, y: y }
      ].map { |pos| base.merge(pos).merge(a: 76) }
      shadows << base.merge(x: x, y: y, a: 255)
    end
  end
end