# frozen_string_literal: true

class HunterBlob < Zif::CompoundSprite
  include Collideable
  include Deadable
  include Scaleable
  include Spatializeable
  include Tickable

  attr_accessor :momentum

  SPRITE_DETAILS = {
    name: "hunterblob",
    layers: [
      name: "main",
      blendmode_enum: :alpha,
      z: 0
    ],
    scales: [
      :large,
      :medium,
      :small
    ]
  }.freeze

  def initialize(
    x: 360,
    y: 960,
    scale: :large
  )
    @tracer_service_name = :tracer
    super(Zif.unique_name("HunterBlob"))

    # mark_and_print("initialize")

    set_position(x, y)
    register_sprites_new
    initialize_scaleable(scale)
    center_sprites
    initialize_collideable
    initialize_tickable

    @alert_threshold = 300
    @sound_collide = "sounds/thump.wav"
    @audio_idle = "sounds/hunterblob.wav"
    @momentum = {
      x: 0,
      y: 0
    }
  end

  def perform_tick
    return unless @active

    spatialize(@name.to_sym) if @active

    speed = 20

    dist = $gtk.args.geometry.distance($gtk.args.state.ship.xy, self.xy).abs
    return if dist > @alert_threshold

    diff_array = Zif.sub_positions($gtk.args.state.ship.xy, self.xy)
    diff_normalized = $gtk.args.geometry.vec2_normalize ({
      x: diff_array[0],
      y: diff_array[1]
    })
    # puts diff_normalized
    # diff_scaled = diff_normalized.map { |k,v| k: v * (1/dist) }
    diff_scaled = diff_normalized.merge(diff_normalized) {|k,v| v*(1/dist) }
    # puts diff_scaled

    @momentum.x += diff_scaled[:x] * speed
    @momentum.y += diff_scaled[:y] * speed

    @x += @momentum[:x]
    @y += @momentum[:y]

    # This is copypasta from Ship
    # And has totally not been tested, because how can I make it go out of bounds?
    if @x + @w > $ui_viewscreen.right
      @x -= (@x + @w - $ui_viewscreen.right)
      @momentum.x *= -1.0
    elsif @x < $ui_viewscreen.left
      @x += $ui_viewscreen.left - @x
      @momentum.x *= -1.0
    end
    if @y + @h > $ui_viewscreen.top
      @y -= (@y + @h - $ui_viewscreen.top)
      @momentum.y *= -1.0
    elsif @y < $ui_viewscreen.bottom
      @y += $ui_viewscreen.bottom - @y
      @momentum.y *= -1.0
    end

    @momentum[:x] *= 0.8
    @momentum[:y] *= 0.8
  end

  def collide_action collidee, facing
    mark_and_print ("Collide with HunterBlob!")
    collidee.add_data_block(name: 'hunterblob', size: 1, corrupted: true)
    kill
  end
end
