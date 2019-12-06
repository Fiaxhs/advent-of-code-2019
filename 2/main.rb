#!/bin/ruby

# Part 1
def run_code memory
	pointer = 0
	while memory[pointer] != 99
		instruction = memory[pointer]
		first_integer = memory[memory[pointer + 1]]
		second_integer = memory[memory[pointer + 2]]
		destination = memory[pointer + 3]
		case instruction
		when 1
			memory[destination] = first_integer + second_integer
		when 2
			memory[destination] = first_integer * second_integer
		end
		pointer += 4
	end
	memory[0]
end

def part_1
	file = File.new("input.txt", "r")
	line = file.gets
	memory = line.split(',').map { |e| e.to_i }
	# replace position 1 with the value 12 and replace position 2 with the value 2
	memory[1] = 12
	memory[2] = 2
	p run_code memory
	file.close
end 

# part 2

def replace_values noun, verb, memory
	memory[1] = noun
	memory[2] = verb
	return memory
end

def part_2
	file = File.new("input.txt", "r")
	line = file.gets
	memory = line.split(',').map { |e| e.to_i }
	file.close

	99.times do |noun|
		99.times do  |verb| 
			result = run_code (replace_values(noun, verb, memory.dup))
			if (result == 19690720) 
				p 100 * noun + verb
				exit
			end
		end
	end
end 

part_2