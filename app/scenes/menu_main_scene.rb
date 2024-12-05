# frozen_string_literal: true
module HuskGame
  class MenuMainScene < HuskEngine::UtilityScene
    # The main menu
    # Should have:
    ## Play
    ## About

    def prepare_scene
      super
      @name = "MainMenu"

      @menu_main_backdrop = Zif::Sprite.new('MenuMainBackdrop').tap do |s|
        s.w = 720
        s.h = 1280
        s.path = 'sprites/menu_main_backdrop.png'
      end
      @render_layers << @menu_main_backdrop
      # $gtk.args.outputs.static_sprites << @menu_main_backdrop

      @menu_main_about = Zif::UI::TwoStageButton.new('MenuMainAbout').tap do |a|
        a.x = 720.half
        a.y = 188
        a.w = 228
        a.h = 97
        a.normal << Zif::Sprite.new('MenuMainAboutNormal').tap do |n|
          n.w = 228
          n.h = 97
          n.path = 'sprites/menu_main_about.png'
        end
        a.pressed << Zif::Sprite.new('MenuMainAboutPressed').tap do |p|
          p.w = 228
          p.h = 97
          p.path = 'sprites/menu_main_about_pressed.png'
        end
        a.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :menu_about
        end
        a.unpress
      end
      $game.services[:input_service].register_clickable @menu_main_about
      @render_layers << @menu_main_about

      @menu_main_play = Zif::UI::TwoStageButton.new('MenuMainPlay').tap do |a|
        a.x = 720.half
        a.y = 340
        a.w = 204
        a.h = 117
        a.normal << Zif::Sprite.new('MenuMainPlayNormal').tap do |n|
          n.w = 204
          n.h = 117
          n.path = 'sprites/menu_main_play.png'
        end
        a.pressed << Zif::Sprite.new('MenuMainPlayPressed').tap do |p|
          p.w = 204
          p.h = 117
          p.path = 'sprites/menu_main_play.png'
        end
        a.on_mouse_up = lambda do |_sprite, _point|
          return unless @ready
          exit_scene :room
        end
        a.unpress
      end
      $game.services[:input_service].register_clickable @menu_main_play
      @render_layers << @menu_main_play

      $gtk.args.audio[:splash_music] ||= {
        input: "music/Lucas_HuskGame_intro_DnB.wav",
        looping: true,
        gain: 0.4
      }
    end

    def unload_scene
      super

      # remove all the audio
      $gtk.args.audio.clear
    end
  end
end