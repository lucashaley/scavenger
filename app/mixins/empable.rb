module HuskEngine
  module Empable
    include Soundable

    attr_accessor :emp_sound
    attr_accessor :emp_low, :emp_medium
    def initialize_empable
      $game.services[:emp_service].register_empable self

      @emp_low = 120
      @emp_medium = 360

      # this needs to be the entity's reaction to EMP, not the EMP itself
      # @emp_sound = 'sounds/emp_blast.wav'

      raise StandardError "#{class_name}: method ~handle_emp_low~ is not defined" \
        unless self.class.instance_methods.include?(:handle_emp_low)
      raise StandardError "#{class_name}: method ~handle_emp_low~ is not defined" \
        unless self.class.instance_methods.include?(:handle_emp_medium)
      raise StandardError "#{class_name}: method ~handle_emp_low~ is not defined" \
        unless self.class.instance_methods.include?(:handle_emp_high)
    end

    # Override this, or add each level method.
    def handle_emp emp_level
      puts "Empable handle_emp: #{emp_level}"

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