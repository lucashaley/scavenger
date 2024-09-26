module HuskEngine
  module Empable
    include Soundable

    attr_accessor :emp_sound
    attr_accessor :emp_low, :emp_medium
    def initialize_empable
      $game.services[:emp_service].register_empable self

      @emp_low = 120
      @emp_medium = 360

      @emp_sound = 'sounds/emp_blast.wav'
    end

    # Override this, or add each level method.
    def handle_emp emp_level
      puts "Empable handle_emp: #{emp_level}"

      play_once @emp_sound unless @emp_sound.nil?

      # case emp_level
      # when :low
      #   # puts "LOW!"
      #   handle_emp_low
      # when :medium
      #   # puts "MEDIUM!"
      #   handle_emp_medium
      # when :high
      #   # puts "HIGH!"
      #   handle_emp_high
      # end

      if emp_level <= @emp_low
        puts "MINOR"
        handle_emp_low emp_level
      elsif emp_level > @emp_low && emp_level <= @emp_medium
        puts "MAJOR"
        handle_emp_medium emp_level
      elsif emp_level > @emp_medium
        puts "KILL"
        handle_emp_high emp_level
      end
    end
  end
end