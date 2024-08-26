def tick(args)
  args.state.sample_rate ||= 44_100
  args.state.synthesizer ||= Synthesizer.new(args.state.sample_rate)
  args.audio.volume = if !args.inputs.keyboard.has_focus && Kernel.tick_count != 0
                        0.4
                      else
                        1.0
                      end
  channel_1 = args.state.synthesizer.generate_square_wave_1(args.state.sample_rate, 440)
  channel_2 = args.state.synthesizer.generate_square_wave_2(args.state.sample_rate, 830.6094)
  channel_3 = args.state.synthesizer.generate_square_wave_3(args.state.sample_rate, 659.2551)
  channel_4 = args.state.synthesizer.generate_square_wave_4(args.state.sample_rate, 783.9909)
  args.audio[:ch1] ||= { input: [1, args.state.sample_rate, channel_1], gain: 0.1 }
  args.audio[:ch2] ||= { input: [1, args.state.sample_rate, channel_2], gain: 0.1 }
  args.audio[:ch3] ||= { input: [1, args.state.sample_rate, channel_3], gain: 0.1 }
  args.audio[:ch4] ||= { input: [1, args.state.sample_rate, channel_4], gain: 0.1 }
  index = 0
  while index < args.state.synthesizer.frame_size
    args.outputs.sprites << {
      x: 20 + (index * 2),
      y: 360 + ((channel_1.call[index] + channel_2.call[index] + channel_3.call[index] + channel_4.call[index]) * 40),
      w: 9,
      h: 9,
      angle: index,
      path: "mygame/sprites/triangle/equilateral/indigo.png"
    }
    index += 4
  end
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

class Synthesizer
  attr_accessor :period_size, :frame_size, :output, :output_buffer, :current_point

  def initialize(sample_rate)
    @period_size = [0, 0, 0, 0]
    @frame_size = (sample_rate / 60).ceil
    init_range = Range.new(0, @frame_size * 2 - 1).to_a
    @output = [init_range, init_range, init_range, init_range]
    @output_buffer = [init_range, init_range, init_range, init_range]
    @current_point = 0
  end
  def generate_sin_wave(channel, sample_rate, frequency)
    @period_size[channel] = (sample_rate / frequency).ceil
    @output[channel] = (0...@period_size[channel]).map { |i|
      Math.sin((2 * Math::PI) / (@period_size[channel]) * i)
    } * (sample_rate / @period_size[channel])
    @current_point = @output_buffer[channel][@frame_size] % @period_size[channel]
    @output_buffer[channel] = (@current_point..(@current_point + @frame_size * 2 - 1)).to_a
    # @output[channel-1] = @output[channel-1].map {
    #   |i|
    #   if i < 0.0
    #     -1.0
    #   else
    #     1.0
    #   end
    # }
    return -> { @output[channel] }
  end

  def generate_square_wave_1(sample_rate, frequency)
    generate_sin_wave(0, sample_rate, frequency)
  end

  def generate_square_wave_2(sample_rate, frequency)
    generate_sin_wave(1, sample_rate, frequency)
  end

  def generate_square_wave_3(sample_rate, frequency)
    generate_sin_wave(2, sample_rate, frequency)
  end

  def generate_square_wave_4(sample_rate, frequency)
    generate_sin_wave(3, sample_rate, frequency)
  end
end