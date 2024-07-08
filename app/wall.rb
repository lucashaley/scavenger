class Wall < Zif::Sprite
  include Bounceable

  def initialize (
    prototype,
    x=0,
    y=0,
    bounce=0.8
  )
    # puts 'Wall initialize'
    # puts x
    # puts y
    # puts bounce
    super()
    assign(prototype.to_h)

    @x = x
    @y = y
    @bounce = bounce
  end

  def collide_x_with c
    bounce_x_off c
  end
  def collide_y_with c
    bounce_y_off c
  end
end
