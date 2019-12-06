#!/bin/ruby
@start = 108457
@finish = 562041

# Part 1
@possible = []
def create_password (previous, x, step)
	for i in x..9
		current = previous + i * 10**step
		if step != 0
			create_password(current, i, step -1)
		else
			if current > @start && current < @finish && current.to_s.match(/11|22|33|44|55|66|77|88|99/)
				@possible.push(current)
			end
		end
	end
end

create_password(0, @start.digits[-1], 5)

p @possible.length

# Part 2
@possible = []
def create_password_2 (previous, x, step)
	def has_strict_double number
		repartition = {}
		number.to_s.split('').each do |i|
			repartition[i] = repartition[i] + 1 rescue repartition[i] = 1
		end
		return repartition.has_value?(2)
	end
	for i in x..9
		current = previous + i * 10**step
		if step != 0
			create_password_2(current, i, step -1)
		else
			if current > @start && current < @finish && has_strict_double(current)
				@possible.push(current)
			end
		end
	end
end

create_password_2(0, @start.digits[-1], 5)
p @possible.length