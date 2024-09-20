module Tickable
  def initialize_tickable
    $game.services[:tick_service].register_tickable self
  end

  # Override this!
  def perform_tick

  end
end