module Services
  # This service facilitates keeping track of and running {Zif::Action::Actionable}s that need updating every tick.
  #
  # Specifically, every tick {Zif::Game} will invoke {#run_all_actions} on this service.
  # In turn, this calls {Zif::Action::Actionable#perform_actions} on all {Zif::Action::Actionable}s objects which have
  # been previously registered using {#register_actionable}.
  # @see Zif::Action::Actionable
  class TickService
    # @return [Array<Zif::Action::Actionable>] The list of {Zif::Action::Actionable}s to check each tick
    attr_reader :tickables

    # ------------------
    # @!group 1. Public Interface

    # Calls {reset_actionables}
    def initialize
      reset_tickables
    end

    # Resets the {actionables} array.
    def reset_tickables
      @tickables = []
    end

    # Adds an {Zif::Actions::Actionable} to the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def register_tickable(tickable)
      unless tickable.is_a?(Tickable)
        raise ArgumentError, 'Services::TickService#register_tickable:' \
          " #{tickable} is not a Tickable"
      end

      @tickables << tickable
    end

    # Removes an {Zif::Actions::Actionable} from the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def remove_tickable(tickable)
      @tickables.delete(tickable)
    end

    # Moves an {Zif::Actions::Actionable} to the start of the {actionables} array, so it is processed first
    # @param [Zif::Actions::Actionable] actionable
    def promote_tickable(tickable)
      @tickables.unshift(remove_tickable(tickable))
    end

    # Moves an {Zif::Actions::Actionable} to the end of the {actionables} array, so it is processed last
    # @param [Zif::Actions::Actionable] actionable
    def demote_tickable(tickable)
      @tickables.push(remove_tickable(tickable))
    end

    # ------------------
    # @!group 2. Private-ish methods

    # Iterate through {actionables} and invoke {Zif::Action::Actionable#perform_actions}
    # Unless you are doing something advanced, this should be invoked automatically by {Zif::Game#standard_tick}
    # @api private
    def run_all_ticks
      tickables_count = @tickables&.length

      return false unless tickables_count&.positive?

      # Avoid blocks here.
      idx = 0
      while idx < tickables_count
        @tickables[idx].perform_tick
        idx += 1
      end

      true
    end
  end
end
