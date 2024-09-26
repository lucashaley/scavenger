module Services
  # This service facilitates keeping track of and running {Zif::Action::Actionable}s that need updating every tick.
  #
  # Specifically, every tick {Zif::Game} will invoke {#run_all_actions} on this service.
  # In turn, this calls {Zif::Action::Actionable#perform_actions} on all {Zif::Action::Actionable}s objects which have
  # been previously registered using {#register_actionable}.
  # @see Zif::Action::Actionable
  class EmpService
    # @return [Array<Zif::Action::Actionable>] The list of {Zif::Action::Actionable}s to check each tick
    attr_reader :empables

    # ------------------
    # @!group 1. Public Interface

    # Calls {reset_actionables}
    def initialize
      reset_empables
    end

    # Resets the {actionables} array.
    def reset_empables
      @empables = []
    end

    # Adds an {Zif::Actions::Actionable} to the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def register_empable(empable)
      unless empable.is_a?(HuskEngine::Empable)
        raise ArgumentError, 'Services::EmpService#register_empable:' \
          " #{empable} is not a Empable"
      end

      # puts "Registering empable: #{empable.name}"
      @empables << empable
    end

    # This doesn't work yet
    # def tick_registered?(name)
    #   # @tickables.key?(name)
    # end

    # Removes an {Zif::Actions::Actionable} from the {actionables} array.
    # @param [Zif::Actions::Actionable] actionable
    def remove_empable(empable)
      @empables.delete(empable)
    end

    # Moves an {Zif::Actions::Actionable} to the start of the {actionables} array, so it is processed first
    # @param [Zif::Actions::Actionable] actionable
    def promote_empable(empable)
      @empables.unshift(remove_empable(empable))
    end

    # Moves an {Zif::Actions::Actionable} to the end of the {actionables} array, so it is processed last
    # @param [Zif::Actions::Actionable] actionable
    def demote_empable(empable)
      @empables.push(remove_empable(empable))
    end

    # ------------------
    # @!group 2. Private-ish methods

    # Iterate through {actionables} and invoke {Zif::Action::Actionable#perform_actions}
    # Unless you are doing something advanced, this should be invoked automatically by {Zif::Game#standard_tick}
    # @api private
    def run_all_emps(emp_level)
      # puts "EmpService: run_all_emps(#{emp_level})\n#{@empables}\n\n"
      empables_count = @empables&.length

      return false unless empables_count&.positive?

      # Avoid blocks here.
      idx = 0
      while idx < empables_count
        mark = @empables[idx].name
        @empables[idx].handle_emp(emp_level) if @empables[idx].active?
        idx += 1
      end

      true
    end
  end
end
