#!/bin/ruby
require 'chunky_png'

file = File.new("input.txt", "r")
line = file.gets
file.close

class Amp
	def initialize(memory)
      @memory = memory
	  @pointer = 0
	  @first = true
	  @ret = nil
	  @relative = 0
	  100000.times do
	  	@memory.push 0
	  end
   end

	def read (n, mode)
		case mode 
		when 0
			@memory[n].to_i
		when 1
			n
		when 2
			@memory[n + @relative].to_i
		end
	end

	def run ()
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
				@memory[@memory[@pointer + 3] + (mode_third == 2 ? @relative : 0) ] = read(@memory[@pointer + 1], mode_first) + read(@memory[@pointer + 2], mode_second)
				step = 4
			when 2
				@memory[@memory[@pointer + 3]+ (mode_third == 2 ? @relative : 0)] = read(@memory[@pointer + 1], mode_first) * read(@memory[@pointer + 2], mode_second)
				step = 4
			when 3
				p "Type something"
				value = gets.chomp.to_i
				if mode_first == 2
					@memory[@memory[@pointer  + 1]+ @relative] = value
				else
					@memory[@memory[@pointer + 1]] = value
				end
				step = 2
			when 4
				p read(@memory[@pointer + 1], mode_first)
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
					@memory[@memory[@pointer + 3]+ (mode_third == 2 ? @relative : 0)] = 1
				else
					@memory[@memory[@pointer + 3]+ (mode_third == 2 ? @relative : 0)] = 0
				end
				step = 4
			when 8
				fparam = read(@memory[@pointer + 1], mode_first)
				sparam = read(@memory[@pointer + 2], mode_second)
				if fparam == sparam
					@memory[@memory[@pointer + 3]+ (mode_third == 2 ? @relative : 0)] = 1
				else
					@memory[@memory[@pointer + 3]+ (mode_third == 2 ? @relative : 0)] = 0
				end
				step = 4
			when 9
				param = read(@memory[@pointer + 1], mode_first)
				@relative += param
				step = 2
			when 99
				exit
			end
			
			@pointer += step
		end
	end
end
file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
file.close

A = Amp.new(memory)
A.run()