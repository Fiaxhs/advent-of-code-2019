#!/bin/ruby
# Holds "recipe" for a compound
@conversions = {}
# How many steps to get said compound
@levels = {"ORE" => 0}
# Simple list of all compounds
@all_compounds = []

file = File.new("input.txt", "r")
while line = file.gets
	ingredients, product = line.chomp.split(' => ')
	/(\d+)\s+(\w+)/.match product
	product_name = $2
	@conversions[product_name] = {:count => $1.to_i, :compounds => []}
	@all_compounds.push product_name
	ingredients.split(',').each do |ingredient|
		/(\d+)\s+(\w+)/.match ingredient
		number = $1.to_i
		compound = $2
		@conversions[product_name][:compounds].push({compound => number})
	end
	# 1 step compounds (X needs n ORE)
	if @conversions[product_name][:compounds].size == 1 and @conversions[product_name][:compounds].first.keys[0] == "ORE"
		@levels[product_name] = 1
	end
end
file.close

# assign level to each compound
current_level = 1
while @levels.size < @conversions.size
	@all_compounds.each do |compound|
		next if !@levels[compound].nil?
		if @conversions[compound][:compounds].all? { |name_count| 
			cname = name_count.keys[0] 
			!@levels[cname].nil? and @levels[cname] <= current_level 
		}
			@levels[compound] = current_level + 1
		end
	end
	current_level += 1
end

# reduce list of compounds so they're unique
def group to_group
	grouped = {}
	to_group.each { |current| 
		key, value = current.first
		grouped[key] = grouped[key] + value rescue grouped[key] = value
	}
	grouped = grouped.map { |key, value| {key=>value} }
	return grouped
end

# Takes highest level comp, replace by recipe * ratio, repeat until all is ORE
def convert to_convert	
	max_level, max_idx = to_convert.each_with_index.max_by {|compound, idx|
		cname =  compound.keys[0]
		@levels[cname]
	}
	if @levels[max_level.keys[0]] == 0
		return group(to_convert).first.first[1]
	end
	compound_name, compound_count = max_level.first
	ratio = compound_count.fdiv(@conversions[compound_name][:count]).ceil
	replace_by = @conversions[compound_name][:compounds].map do |next_c|
		next_compound_name, next_compound_count = next_c.first
		{next_compound_name => next_compound_count * ratio}
	end
	to_convert[max_idx] = replace_by
	return convert(group(to_convert.flatten))
end

def change_fuel(n)
	@conversions["FUEL"][:compounds].dup.map do |c|
		cname, ccount = c.first
		{cname => n * ccount}
	end
end

# Part 1
p convert(@conversions["FUEL"][:compounds].dup)

# Part 2
t1 = Time.now
i = 1
step = 100000
max_fuel = 0
@diffs = {}
used_ore = nil
loop do
	old_used = used_ore
	used_ore = convert(change_fuel(i))
	if used_ore > 1000000000000
		if step > 1
			i = i - step
			step = step /10
		else
			t2 = Time.now
			delta = t2 - t1 # in seconds
			p "Max #{i-1} FUEL, in #{delta}s"
			break
		end
	end
	i = i + step
end
