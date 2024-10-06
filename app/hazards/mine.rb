module HuskGame
  class Mine < Zif::CompoundSprite
    include HuskEngine::Collideable
    include HuskEngine::Deadable
    include HuskEngine::Scaleable
    include HuskEngine::Bufferable
    include HuskEngine::Spatializeable
    include HuskEngine::Tickable
    include HuskEngine::Shadowable

    attr_accessor :damage, :blown
    attr_accessor :audio_idle

    SPRITE_DETAILS = {
      name: "mine",
      layers: [
        {
          name: "main",
          animations: [
            {
              name: "idle",
              frames: 3,
              hold: 10,
              repeat: :forever
            }
          ],
          blendmode_enum: :alpha,
          z: 0
        },
        {
          name: "fx",
          blendmode_enum: :add,
          z: 2,
          animations: [
            {
              name: "blow",
              frames: 7,
              hold: 2,
              repeat: :once
            }
          ]
        },
        {
          name: "shadow",
          blendmode_enum: BLENDMODE[:multiply],
          z: -1
        }
      ],
      scales: {
        large: {
          w: 64,
          h: 64
        },
        medium: {
          w: 40,
          h: 40
        },
        small: {
          w: 32,
          h: 32
        },
        tiny: {
          w: 16,
          h: 16
        }
      }
    }.freeze

    def initialize(
      x: 0,
      y: 0,
      scale: :large,
      damage: 0.4
    )
      super(Zif.unique_name("Mine"))
      # module_array = self.class.included_modules
      # puts "Modules: #{ module_array.select { |m| m.to_s.start_with? ("HuskEngine") } }"

      set_position(x,y)

      initialize_shadowable
      register_sprites_new
      initialize_scaleable(scale)
      center_sprites
      initialize_collideable
      initialize_bufferable(:double)
      initialize_tickable

      @damage = damage
      @blown = false

      # initialize_collision
      @sound_collide = "sounds/thump.wav"

      animation_name = "mine_main_#{scale}"
      @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:idle)

      @audio_idle = 'sounds/mine_idle.wav'
    end

    def perform_tick
      spatialize(@name.to_sym)
      perform_shadow_tick
    end

    def collide_action collidee, facing
      puts 'mine collide_action'

      return if @blown

      @sprites.find { |s| s.name == "mine_main_#{@scale}" }.hide

      blowback = 6

      collidee.change_health -0.25, facing
      case facing
      when :north
        # collidee.health_north *= @damage
        collidee.momentum.y += blowback
      when :south
        # collidee.health_south *= @damage
        collidee.momentum.y += -blowback
      when :east
        # collidee.health_east *= @damage
        collidee.momentum.x += blowback
      when :west
        # collidee.health_west *= @damage
        collidee.momentum.x += -blowback
      end

      # Damage the husk
      $game.scene.husk.damage 60

      # play the animation
      animation_name = "mine_fx_#{@scale}"
      @sprites.find { |s| s.name == animation_name }.run_animation_sequence(:blow)
      # And get rid of the mine
      # kill
      @blown = true
    end

    def complete_animation(animation)
      puts "complete_animation"
      case animation
      when :blow
        puts "complete_animation: blow"
        kill
      end
    end
  end
end
