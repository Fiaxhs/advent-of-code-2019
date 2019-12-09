#!/bin/ruby


def run_code (memory, phase, previous)
	@memory = memory
	pointer = 0
	def read (n, mode)
		mode === 1 ? n : @memory[n].to_i
	end
	first = true

	while true
		instruction = "%05d" % memory[pointer]
		action = instruction[-2..-1].to_i
		mode_first = instruction[-3].to_i
		mode_second = instruction[-4].to_i
		mode_third = instruction[-5].to_i
		step = 0
		case action
		when 1
			memory[memory[pointer + 3]] = read(memory[pointer + 1], mode_first) + read(memory[pointer + 2], mode_second)
			step = 4
		when 2
			memory[memory[pointer + 3]] = read(memory[pointer + 1], mode_first) * read(memory[pointer + 2], mode_second)
			step = 4
		when 3
			# puts "Type something"
			value = first ? phase : previous
			memory[memory[pointer + 1]] = value
			first = false
			step = 2
		when 4
			return read(memory[pointer + 1], mode_first)
			step = 2
		when 5
			param = read(memory[pointer + 1], mode_first)
			if param != 0
				pointer = read(memory[pointer + 2], mode_second)
			else
				step = 3
			end
		when 6
			param = read(memory[pointer + 1], mode_first)
			if param == 0
				pointer = read(memory[pointer + 2], mode_second)
			else
				step = 3
			end
		when 7
			fparam = read(memory[pointer + 1], mode_first)
			sparam = read(memory[pointer + 2], mode_second)
			if fparam < sparam
				memory[memory[pointer + 3]] = 1
			else
				memory[memory[pointer + 3]] = 0
			end
			step = 4
		when 8
			fparam = read(memory[pointer + 1], mode_first)
			sparam = read(memory[pointer + 2], mode_second)
			if fparam == sparam
				memory[memory[pointer + 3]] = 1
			else
				memory[memory[pointer + 3]] = 0
			end
			step = 4
		when 99
			exit
		end
		pointer += step
	end
end

phases = [0,1,2,3,4].permutation.to_a
@max = -Float::INFINITY
@best_phase = nil

file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
file.close
phases.each do |phase|
	input = 0
	i = 0
	5.times do
		input = run_code(memory.dup, phase[i], input)
		i += 1
	end
	if input > @max
		@max = input
		@best_phase = phase
	end
end
puts @best_phase.join(',')
puts @max

# part 2

class Amp
	def initialize(memory, phase)
      @memory = memory
      @phase = phase
	  @pointer = 0
	  @first = true
	  @ret = nil
   end

	def read (n, mode)
		mode === 1 ? n : @memory[n].to_i
	end

	def run (prev_output)
		@ret = nil
		while true
			instruction = "%05d" % @memory[@pointer]
			action = instruction[-2..-1].to_i
			mode_first = instruction[-3].to_i
			mode_second = instruction[-4].to_i
			mode_third = instruction[-5].to_i
			step = 0
			case action
			when 1
				@memory[@memory[@pointer + 3]] = read(@memory[@pointer + 1], mode_first) + read(@memory[@pointer + 2], mode_second)
				step = 4
			when 2
				@memory[@memory[@pointer + 3]] = read(@memory[@pointer + 1], mode_first) * read(@memory[@pointer + 2], mode_second)
				step = 4
			when 3
				# puts "Type something"
				value = @first ? @phase : prev_output
				@memory[@memory[@pointer + 1]] = value
				@first = false
				step = 2
			when 4
				@ret = read(@memory[@pointer + 1], mode_first)
				step = 2
			when 5
				param = read(@memory[@pointer + 1], mode_first)
				if param != 0
					@pointer = read(@memory[@pointer + 2], mode_second)
				else
					step = 3
				end
			when 6
				param = read(@memory[@pointer + 1], mode_first)
				if param == 0
					@pointer = read(@memory[@pointer + 2], mode_second)
				else
					step = 3
				end
			when 7
				fparam = read(@memory[@pointer + 1], mode_first)
				sparam = read(@memory[@pointer + 2], mode_second)
				if fparam < sparam
					@memory[@memory[@pointer + 3]] = 1
				else
					@memory[@memory[@pointer + 3]] = 0
				end
				step = 4
			when 8
				fparam = read(@memory[@pointer + 1], mode_first)
				sparam = read(@memory[@pointer + 2], mode_second)
				if fparam == sparam
					@memory[@memory[@pointer + 3]] = 1
				else
					@memory[@memory[@pointer + 3]] = 0
				end
				step = 4
			when 99
				return @ret, false
			end
			@pointer += step
			if @ret != nil
				return @ret, true
			end
		end
	end

end
phases = [5,6,7,8,9].permutation.to_a
@max = -Float::INFINITY
@best_phase = nil

file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
file.close
phases.each do |phase|
	A = Amp.new(memory.dup, phase[0])
	B = Amp.new(memory.dup, phase[1])
	C = Amp.new(memory.dup, phase[2])
	D = Amp.new(memory.dup, phase[3])
	E = Amp.new(memory.dup, phase[4])
	amps = [A,B,C,D,E]
	current_amp = 0
	input = 0
	last_input = 0
	loop do
		last_input = input
		input, should_continue = amps[current_amp % 5].run(input)
		current_amp += 1
		break if !should_continue
	end
	if last_input > @max
		@max = last_input
		@best_phase = phase
	end
end

puts @best_phase.join(',')
puts @max