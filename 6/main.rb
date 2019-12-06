#!/bin/ruby

@map = {}

def find_orbits
	file = File.new("input.txt", "r")
	# A = {:orbits => B, :moons => [C,D,E]}
	
	while line = file.gets
		objects = line.chomp.split(')')
		if @map[objects[1]].nil?
			 @map[objects[1]] = {:orbits => objects[0], :moons => []}
		else
			@map[objects[1]][:orbits] = objects[0] 
		end
		if @map[objects[0]].nil?
			@map[objects[0]] = {:moons => [objects[1]], :orbits => nil}
		else		
			@map[objects[0]][:moons].push(objects[1])
		end
	end
	file.close
	p recurse_count_moons("COM", 1)
end

def recurse_count_moons (planet, level)
	count = @map[planet][:moons].length * level
	@map[planet][:moons].each do |moon|
		count += recurse_count_moons(moon, level+1)
	end
	count
end
find_orbits

def find_jumps
	me_to_com = {}
	current = "YOU"
	jumps = {}
	steps = 0
	while @map[current][:orbits] != "COM"
		currently_orbiting = @map[current][:orbits]
		me_to_com[currently_orbiting] = steps
		current = currently_orbiting
		steps += 1
	end
	steps = 0
	current = "SAN"
	while @map[current][:orbits] != "COM"
		currently_orbiting = @map[current][:orbits]
		if !me_to_com[currently_orbiting].nil?
			p steps + me_to_com[currently_orbiting]
			exit
		end
		current = currently_orbiting
		steps += 1
	end
end

find_jumps

