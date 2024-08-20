class Attractor < Zif::CompoundSprite
  include Collideable
  include Bounceable
  include Deadable
  include Effectable
  include Scaleable

  BOUNCE_SCALES = {
    large: 0.8,
    medium: 0.4,
    small: 0.1
  }

  def initialize(
    x = 0,
    y = 0,
    scale = :large,
    effect_strength = 50
  )
    puts "\n\Attractor Initialize\n======================"
    super()
    # assign(prototype.to_h)

    @x = x
    @y = y

    collate_sprites "attractor"
    set_scale scale

    # initialize_collision
    @bounce = 0.9
    @sound_collide = "sounds/thump.wav"

    @effect_strength = effect_strength
    @effect_active = false
  end

  def collide_action(collidee, facing)
    puts 'collide_action'
    play_once @sound_collide
    if facing == :east || facing == :west
      bounce_x_off collidee, facing
    end
    if facing == :north || facing == :south
      bounce_y_off collidee, facing
    end
  end

  def perform_effect
    return unless @effect_active

    # Do we want to normalize here?
    effect_vector = $gtk.args.geometry.vec2_normalize({
      x: @x - @effect_target.x,
      y: @y - @effect_target.y
    })

    distance = $gtk.args.geometry.distance self, @effect_target
    effect_vector.x *= (1/distance) * effect_strength # @effect_strength
    effect_vector.y *= (1/distance) * effect_strength # @effect_strength
    # puts effect_vector

    # Do we want to be just adding to the momentum? Seems wrong
    @effect_target.effect.x += effect_vector.x
    @effect_target.effect.y += effect_vector.y
  end
end
