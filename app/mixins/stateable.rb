# frozen_string_literal: true
module HuskEngine
  module Stateable
    attr_reader :state, :state_name

    def initialize_stateable(state_name, initial_state: :idle)
      raise ArgumentError if state_name.nil?

      @state_name = state_name
      @state = initial_state
      @state_transitions = {}

      $gtk.args.state[state_name.to_sym] ||= []
      $gtk.args.state[state_name.to_sym] << self
    end

    # Define valid transitions: transition(:idle, :hunting, :hunting)
    # Or multiple: transitions(:idle, [:hunting, :stunned])
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def state_machine(transitions = {})
        define_method(:build_state_transitions) do
          transitions.each do |from, to_states|
            @state_transitions[from] = Array(to_states)
          end
        end
      end
    end

    def change_state(new_state)
      return if @state == new_state

      if @state_transitions.any?
        allowed = @state_transitions[@state]
        unless allowed && allowed.include?(new_state)
          return
        end
      end

      old_state = @state
      @state = new_state

      callback = :"on_#{new_state}"
      send(callback) if respond_to?(callback, true)
    end
  end
end
