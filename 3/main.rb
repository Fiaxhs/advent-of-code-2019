#!/bin/ruby

# Part 1

def find_min_dist 
	file = File.new("input.txt", "r")
	@map = {}
	@intersections = []
	def walk (coord, wire_number)
		if @map[coord] and @map[coord] != wire_number
			@intersections.push(coord)
		else
			@map[coord] = wire_number
		end
	end
	i = 1
	while (line = file.gets)
		i += 1
		current = {:x => 0, :y => 0}
		line.split(',').each do |instruction| 
			direction = instruction[0]
			distance = instruction[1..-1].to_i
			case direction
			when "R"
				distance.times do |dist|
					walk({:x => (current[:x] + dist + 1), :y => current[:y]}, i)
				end
				current[:x] += distance
			when "L"
				distance.times do |dist|
					walk({:x => current[:x] - dist - 1, :y => current[:y]}, i)
				end
				current[:x] -= distance
			when "U"
				distance.times do |dist|
					walk({:y => current[:y] + dist + 1, :x => current[:x]}, i)
				end
				current[:y] += distance
			when "D"
				distance.times do |dist|
					walk({:y => current[:y] - dist - 1, :x => current[:x]}, i)
				end
				current[:y] -= distance
			end
		end
	end
	file.close
	min_dist = 9999999999999999999999
	@intersections.each do |coords|
		dist = coords[:x].abs() + coords[:y].abs()
		min_dist = dist if dist < min_dist
	end
	p min_dist

end

# find_min_dist


# Part 2

def find_min_steps 
	file = File.new("input.txt", "r")
	@map = {}
	@intersections = []
	def walk (coord, wire_number, steps)
		if @map[coord] and not @map[coord][wire_number]
			@intersections.push(@map[coord][wire_number-1] + steps)
		else
			@map[coord] = {wire_number => steps}
		end
	end
	i = 1
	while (line = file.gets)
		i += 1
		current = {:x => 0, :y => 0}
		steps = 1
		line.split(',').each do |instruction| 
			direction = instruction[0]
			distance = instruction[1..-1].to_i
			case direction
			when "R"
				distance.times do |dist|
					walk({:x => (current[:x] + dist + 1), :y => current[:y]}, i, steps)
					steps += 1
				end
				current[:x] += distance
			when "L"
				distance.times do |dist|
					walk({:x => current[:x] - dist - 1, :y => current[:y]}, i, steps)
					steps += 1
				end
				current[:x] -= distance
			when "U"
				distance.times do |dist|
					walk({:y => current[:y] + dist + 1, :x => current[:x]}, i, steps)
					steps += 1
				end
				current[:y] += distance
			when "D"
				distance.times do |dist|
					walk({:y => current[:y] - dist - 1, :x => current[:x]}, i, steps)
					steps += 1
				end
				current[:y] -= distance
			end
		end
	end
	file.close
	min_dist = 9999999999999999999999
	@intersections.each do |steps|
		min_dist = steps if steps < min_dist
	end
	p min_dist

end


find_min_steps	

