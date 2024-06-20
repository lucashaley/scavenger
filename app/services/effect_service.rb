module Services
  # This service facilitates keeping track of and running {Zif::Action::Actionable}s that need updating every tick.
  #
  # Specifically, every tick {Zif::Game} will invoke {#run_all_actions} on this service.
  # In turn, this calls {Zif::Action::Actionable#perform_actions} on all {Zif::Action::Actionable}s objects which have
  # been previously registered using {#register_actionable}.
  # @see Zif::Action::Actionable
  class EffectService
    # @return [Array<Zif::Action::Actionable>] The list of {Zif::Action::Actionable}s to check each tick
    attr_reader :effectables

    # ------------------
    # @!group 1. Public Interface

    # Calls {reset_actionables}
    def initialize
      reset_effectables
    end

    # Resets the {actionables} array.
    def reset_effectables
      @effectables = []
    end

    # Adds an {Zif::Actions::Actionable} to the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def register_effectable(effectable)
      unless effectable.is_a?(Effectable)
        raise ArgumentError, 'Services::EffectService#register_effectable:' \
                             " #{effectable} is not a Effectable"
      end

      @effectables << effectable
    end

    # Removes an {Zif::Actions::Actionable} from the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def remove_effectable(effectable)
      @effectables.delete(effectable)
    end

    # Moves an {Zif::Actions::Actionable} to the start of the {actionables} array, so it is processed first
    # @param [Zif::Actions::Actionable] actionable
    def promote_effectable(effectable)
      @effectables.unshift(remove_effectable(effectable))
    end

    # Moves an {Zif::Actions::Actionable} to the end of the {actionables} array, so it is processed last
    # @param [Zif::Actions::Actionable] actionable
    def demote_effectable(effectable)
      @effectables.push(remove_effectable(effectable))
    end

    # ------------------
    # @!group 2. Private-ish methods

    # Iterate through {actionables} and invoke {Zif::Action::Actionable#perform_actions}
    # Unless you are doing something advanced, this should be invoked automatically by {Zif::Game#standard_tick}
    # @api private
    def run_all_effects
      effectables_count = @effectables&.length

      return false unless effectables_count&.positive?

      # Avoid blocks here.
      idx = 0
      while idx < effectables_count
        @effectables[idx].perform_effect
        idx += 1
      end

      true
    end
  end
end
