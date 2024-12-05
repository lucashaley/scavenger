# frozen_string_literal: true
module HuskEngine
  module Stateable
    attr_accessor :state_name

    def initialize_stateable state_name
      raise ArgumentError if state_name.nil?

      puts "initialize_stateable: #{state_name}"

      @state_name = state_name
      $gtk.args.state[state_name.to_sym] ||= []

      puts "state: #{$gtk.args.state[state_name.to_sym]}"
      $gtk.args.state[state_name.to_sym] << self
    end
  end
end