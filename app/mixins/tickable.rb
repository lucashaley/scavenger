module HuskEngine
  module Tickable
    def initialize_tickable
      $game.services[:tick_service].register_tickable self

      raise StandardError "#{class_name}: method ~perform_tick~ is not defined" \
        unless self.class.instance_methods.include?(:perform_tick)
    end

    # Override this!
    # def perform_tick
    #   puts "Tickable perform_tick: You haven't provided an override!"
    # end
  end
end