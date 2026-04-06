# frozen_string_literal: true
module HuskEngine
  module Lockable
    attr_accessor :locked, :keyitem, :consuming
    def initialize_lockable(
      locked: false,
      keyitem: nil,
      consuming: false
    )
      @locked = locked
      @keyitem = keyitem
      @consuming = consuming
    end
  end
end