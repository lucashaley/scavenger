module Tickable
  def initialize_tickable
    $game.services[:tick_service].register_tickable self
  end

  # Override this!
  def perform_tick
    puts "Tickable perform_tick: You haven't provided an override!"
  end
end