#!/bin/ruby


def run_code memory
	@memory = memory
	pointer = 0
	def read (n, mode)
		mode === 1 ? n : @memory[n].to_i
	end

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
			p "Type something"
			value = gets.chomp.to_i
			memory[memory[pointer + 1]] = value
			step = 2
		when 4
			p read(memory[pointer + 1], mode_first)
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

file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
p run_code memory
file.close
