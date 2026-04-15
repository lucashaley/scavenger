module Services
  class ParticleService
    attr_reader :emitters

    def initialize
      @emitters = []
    end

    def register(emitter)
      @emitters << emitter
      emitter
    end

    def remove(emitter)
      @emitters.delete(emitter)
    end

    def clear
      @emitters.clear
    end

    def perform_tick
      @emitters.each(&:perform_tick)
    end

    def render
      output = []
      @emitters.each do |e|
        output.concat(e.render)
      end
      output
    end
  end
end
