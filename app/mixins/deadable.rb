module Deadable
  @dead = false

  def is_dead
    @dead
  end

  def kill
    puts "Killing: @{name}"
    @dead = true
    hide
  end
end
