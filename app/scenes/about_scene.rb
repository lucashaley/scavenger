# frozen_string_literal: true
module HuskGame
  class AboutScene < HuskEngine::UtilityScene
    def prepare_scene
      super
      @name = "About"

      @menu_about_backdrop = Zif::Sprite.new('MenuAboutBackdrop').tap do |s|
        s.w = 720
        s.h = 1280
        s.a = 255
        s.path = 'sprites/menu_about_backdrop.png'
      end
      puts @menu_about_backdrop
      @render_layers << @menu_about_backdrop

      @menu_about_back = Zif::UI::TwoStageButton.new('MenuAboutBack').tap do |a|
        a.x = 720.half
        a.y = 188
        a.w = 228
        a.h = 97
        a.normal << Zif::Sprite.new('MenuAboutBackNormal').tap do |n|
          n.w = 228
          n.h = 97
          n.path = 'sprites/menu_main_about.png'
        end
        a.pressed << Zif::Sprite.new('MenuAboutBackPressed').tap do |p|
          p.w = 228
          p.h = 97
          p.path = 'sprites/menu_main_about_pressed.png'
        end
        a.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :menu_main
        end
        a.unpress
      end
      $game.services[:input_service].register_clickable @menu_about_back
      @render_layers << @menu_about_back

      $gtk.args.outputs.static_labels << @info

      $gtk.args.audio[:splash_music] ||= {
        input: "music/Lucas_HuskGame_intro_DnB.wav",
        looping: true,
        gain: 0.4
      }
    end
  end
end
