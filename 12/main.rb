#!/bin/ruby
@moons = ["Io", "Europa", "Ganymede", "Callisto"]
@positions = {}
@velocities = @moons.map{ |moon| [moon, {:x => 0, :y => 0, :z => 0}] }.to_h

file = File.new("input.txt", "r")
@moons.each do |moon|  
	line = file.gets
	/<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/.match line
	@positions[moon] = {:x => $1.to_i, :y => $2.to_i, :z => $3.to_i}
end
file.close

def update_velocities
	[:x, :y, :z].each do |axis|
		sorted_moons = @positions.sort_by { |idx,moon| moon[axis] }

		# left to right
		previous_coord = Float::INFINITY
		moons_on_the_left = 0
		buffer = 0
		sorted_moons.each do |moon|
			current_moon_name, current_moon_coords = moon
			if current_moon_coords[axis] > previous_coord
				moons_on_the_left += buffer
				buffer = 0
			end
			previous_coord = current_moon_coords[axis]
			buffer += 1
			@velocities[current_moon_name][axis] -= moons_on_the_left
		end

		# Right to left
		previous_coord = -Float::INFINITY
		moons_on_the_right = 0
		buffer = 0
		sorted_moons.reverse_each do |moon|
			current_moon_name, current_moon_coords = moon
			if current_moon_coords[axis] < previous_coord
				moons_on_the_right += buffer
				buffer = 0
			end
			previous_coord = current_moon_coords[axis]
			buffer += 1
			@velocities[current_moon_name][axis] += moons_on_the_right
		end
	end
end

def update_positions
	@positions.each do |moon_name,_| 
		@positions[moon_name][:x] += @velocities[moon_name][:x]
		@positions[moon_name][:y] += @velocities[moon_name][:y]
		@positions[moon_name][:z] += @velocities[moon_name][:z]
	end
end

def calc_total_energy
	energies = {}
	@positions.each do |moon_name, position| 
		energies[moon_name] = position[:x].abs + position[:y].abs + position[:z].abs
		energies[moon_name] = energies[moon_name] * (@velocities[moon_name][:x].abs + @velocities[moon_name][:y].abs + @velocities[moon_name][:z].abs)
	end
	p energies.values.sum
end

@universe = @moons.map{ |moon| [moon, {}] }.to_h
def look_for_looped(step)
	[:x, :y, :z].each do |axis|
		key = {axis => {}}
		@moons.each do |moon_name| 
			key[axis][moon_name] = {:v => @velocities[moon_name][axis], :p => @positions[moon_name][axis]}
			if @universe.has_key?(key) and !@orbit_times.has_key?(axis)
				# p "Last time #{axis} was this way, it was at step #{@universe[key]}. It is now step #{step}. #{axis} = #{step - @universe[key]}"
				@orbit_times[axis] = step - @universe[key]
			end
			@universe[key] = step
		end
	end
end

@orbit_times = {}
step = 0
loop do
	look_for_looped(step)
	update_velocities
	update_positions
	break if @orbit_times.size == 3
	step += 1
	calc_total_energy if step == 1000
end
times = @orbit_times.values
p times.reduce(1, :lcm)