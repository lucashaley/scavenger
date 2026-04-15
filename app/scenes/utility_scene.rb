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

      @render_layers = []
      @scene_labels = []
      @pulsing_labels = []
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
        render_pulsing_labels unless @pulsing_labels.empty?
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

    def pulsing_blurred_label(x, y, text, size, min_offset, max_offset, speed: 0.05, alignment_enum: 0)
      @pulsing_labels << {
        x: x, y: y, text: text, size: size,
        min_offset: min_offset, max_offset: max_offset,
        speed: speed, alignment_enum: alignment_enum
      }
    end

    def render_pulsing_labels
      @pulsing_labels.each do |pl|
        wave = (Math.sin(Kernel.tick_count * pl[:speed]) + 1.0) * 0.5
        offset = pl[:min_offset] + (pl[:max_offset] - pl[:min_offset]) * wave
        labels = blurred_label(pl[:x], pl[:y], pl[:text], pl[:size], offset, alignment_enum: pl[:alignment_enum])
        labels.each { |l| $gtk.args.outputs.labels << l }
      end
    end

    def blurred_label(x, y, text, size, offset, alignment_enum: 0)
      base = { text: text, size_enum: size, font: TITLE_FONT, alignment_enum: alignment_enum }.merge(HuskGame::Constants::COLOR_LIGHT_GREEN)
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