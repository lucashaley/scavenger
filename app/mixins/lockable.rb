# frozen_string_literal: true
module HuskEngine
  module Lockable
    attr_accessor :locked, :keyitem, :consuming
    def initialize_lockable(
      locked: false,
      keyitem: nil,
      consuming: false
    )
      puts "initializing lockable"

      @locked = locked
      @keyitem = keyitem
      @consuming = consuming
    end
  end
end