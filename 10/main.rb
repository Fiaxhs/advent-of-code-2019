#!/bin/ruby
file = File.new("input.txt", "r")
i = 0
map = {}
asteroids = []
@width = 0
@height = 0

def get_obstructed (asteroid, seen)
	obstructed = []
	diff_x = seen[:x] - asteroid[:x]
	diff_y = seen[:y] - asteroid[:y]
	divide_by = diff_y.gcd diff_x
	diff_x = diff_x / divide_by
	diff_y = diff_y / divide_by
	i = 1
	loop do
		x = asteroid[:x] + diff_x + (diff_x * i)
		y = asteroid[:y] + diff_y + (diff_y * i)
		if x > @width or x < 0 or y > @height or y < 0
			break
		end
		i += 1
		obstructed.push({:x => x, :y => y})
	end
	return obstructed
end

def valid_coords? coords
	if coords[:x] < 0 or coords[:x] > @width or coords[:y] < 0 or coords[:y] > @height
		return false
	end
	return true
end

def get_spread_coords (asteroid)
	delta = 1
	spread_coords = []
	loop do 
		min_x = asteroid[:x] - delta
		max_x = asteroid[:x] + delta
		min_y = asteroid[:y] - delta
		max_y = asteroid[:y] + delta
		# top and down rows first
		(min_x..max_x).each do |x|
			coords = {:x => x, :y => min_y}
			spread_coords.push(coords) if valid_coords? coords
			coords = {:x => x, :y => max_y}
			spread_coords.push(coords) if valid_coords? coords
		end
		# left and right walls
		min_y += 1
		max_y -= 1
		(min_y..max_y).each do |y|
			coords = {:x => max_x, :y => y}
			spread_coords.push(coords) if valid_coords? coords
			coords = {:x => min_x, :y => y}
			spread_coords.push(coords) if valid_coords? coords
		end

		delta += 1
		break if delta > @height and delta > @width
	end
	return spread_coords
end

while line = file.gets
	line.chomp!
	@width = line.size - 1
	line.each_char.with_index do |char, idx|
		if char == "#"
			coords = {:x => idx, :y => i }
			map[coords] = true
			asteroids.push coords
		end
	end
	i += 1
end
@height = i - 1
file.close

def get_scores(asteroids, map)
	scores = {}
	asteroids.each do |asteroid|
		able_to_see = []
		obstructed = {}
		maze = get_spread_coords(asteroid)
		maze.each do |to_test|
			if obstructed[to_test] != true
				if map[to_test] == true
					able_to_see.push(to_test)
					new_obstructed = get_obstructed(asteroid, to_test)
					new_obstructed.each do |obs|
						obstructed[obs] = true
					end
				end
			end
		end
		scores[asteroid] = able_to_see
	end
	return scores
end

best = get_scores(asteroids, map).max_by{|k,v| v.size}
p best[1].size
p best[0]
# part 2

#{:x=>25, :y=>31}
def get_angle (ray_pos, asteroid)
	x = asteroid[:x] - ray_pos[:x]
	y = asteroid[:y] - ray_pos[:y]
	angle = Math.atan2(x, y) - Math::PI
	angle = angle * 180/Math::PI
	# angle += 360 if angle < 0
	return angle.abs
end

visibles = best[1]
angles = {}
visibles.each do |vis|
	angle = get_angle(best[0], vis);
	distance = (vis[:x] - best[0][:x]).abs + (vis[:y] - best[0][:y]).abs
	info = {vis => distance}
	angles[angle].push(info) rescue angles[angle] = [info]
end
angles = angles.sort_by { |key, value| key }
pp angles
i = 0
@size = angles.size
loop do 
	offset = 0
	@targets
	@idx = nil
	loop do 
		@idx = (i + offset) % @size
		@targets = angles[@idx]
		break if !@targets.empty?
		offset += 1
	end
	target = @targets.sort_by { |_key, value| value }[0]
	if i == 199
		pp angles[@idx]
		break
	else
		angles[@idx] = angles[@idx].drop(1)
		i += 1
	end
end



# debug, kept here for "fun"
# p asteroids[3]
# p asteroids[4]
# p '=-=-'
# p get_obstructed({:x => 6, :y => 3}, {:x => 4, :y => 5})

# from = tested position, to = potential poi
# def path_unobstructed (map, from, to)
# 	diff_x = to[:x] - from[:x]
# 	diff_y = to[:y] - from[:y]
# 	if diff_x == 0 and diff_y == 0
# 		return false
# 	end
# 	divide_by = diff_y.gcd diff_x
# 	diff_x = diff_x / divide_by
# 	diff_y = diff_y / divide_by
# 	(1..divide_by-1).each do |i|
# 		c = {:x => from[:x] + i * diff_x, :y => from[:y] + i * diff_y} 
# 		if map[c] == true
# 			return false
# 		end
# 	end
# 	return true
# end

# bad = scores[{:x => 11, :y => 13}]
# # 
# zob = 0
# woke = []
# asteroids.each do |ast|
# 	if path_unobstructed(map, ast, {:x => 11, :y => 13})
# 		woke.push ast
# 	end
# end
# p bad - woke