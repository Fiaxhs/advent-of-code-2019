#!/bin/ruby

# Part 1

def get_fuel mass
	(mass / 3).floor - 2
end

file = File.new("input.txt", "r")
total_mass = 0
while (line = file.gets)
  total_mass += get_fuel line.to_i
end
file.close

p total_mass

# Part 2

def get_fuel_part2 mass
	ret = (mass / 3).floor - 2
	if ret > 0
		return ret + get_fuel(ret)
	else
		return [0,ret].max
	end

end

file = File.new("input.txt", "r")
total_mass = 0
while (line = file.gets)
  total_mass += get_fuel_part2 line.to_i
end
file.close

p total_mass