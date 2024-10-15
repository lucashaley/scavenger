module HuskGame
  module Roomable
    attr_accessor :room

    def initialize_roomable room
      # puts "ROOMABLE INITIALIZE_ROOMABLE"
      raise StandardError ("initialize_roomable NO ROOM!") if room.nil?
      @room = room
    end
  end
end