#!/bin/ruby

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

	def run (color)
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
				# p "Type something"
				value = color.to_i
				if mode_first == 2
					@memory[@memory[@pointer  + 1]+ @relative] = value
				else
					@memory[@memory[@pointer + 1]] = value
				end
				step = 2
			when 4
				# p read(@memory[@pointer + 1], mode_first)
				r = read(@memory[@pointer + 1], mode_first)
				if @ret
				 	@ret.push(r)
				 	@pointer += 2
				 	return @ret
				 else
				 	@ret = [r]
				 end 
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
				break
			end
			
			@pointer += step
		end
	end
end
file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
file.close

dir_index = 0
directions = [
	{:x => 0, :y=> 1}, #up
	{:x => 1, :y=> 0}, #right
	{:x => 0, :y=> -1}, #down
	{:x => -1, :y=> 0} #left
]
dir = ["up", "right", "down", "left"]

# 0 is black
# 1 is white
grid = {}
position = {:x => 0, :y => 0}

testi = 0
robot = Amp.new(memory)
# [color to paint, direction (0 = left, 1 = right)]
while true
	current_color = grid.has_key?(position) ? grid[position] : 1
	instructions =  robot.run(current_color)
	break if instructions.nil?
	if instructions[1] == 0
		dir_index = dir_index - 1
	elsif instructions[1] == 1
		dir_index = dir_index + 1
	else 
		p 'error'
		exit 
	end
	dir_index = dir_index % 4
	grid[position.dup] = instructions[0]
	position[:x] = position[:x] + directions[dir_index][:x]
	position[:y] = position[:y] + directions[dir_index][:y]
end
p grid.size
keys = grid.keys
minmax_y = keys.map { |k| k[:y] }.minmax
minmax_x = keys.map { |k| k[:x] }.minmax
p minmax_y
p minmax_x
disp = [' ', '▤']
lines = []
(minmax_y.first..minmax_y.last).each do |y|
	line = []
	(minmax_x.first..minmax_x.last).each do |x|
		position = {:x => x, :y => y}
		color = grid.has_key?(position) ? grid[position] : 1
		line.push(disp[color])
	end
	lines.push(line.join(''))
end

lines.reverse_each { |e|  p e  }