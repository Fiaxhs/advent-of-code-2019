#!/bin/ruby
require 'curses'
require 'io/console'
Curses.noecho
Curses.init_screen
def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

class Amp
	def initialize(memory)
      @memory = memory
	  @pointer = 0
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

	def run (next_move)
		while true
			instruction = "%05d" % @memory[@pointer]
			# p instruction
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
				dir = next_move
				if mode_first == 2
					@memory[@memory[@pointer  + 1]+ @relative] = dir
				else
					@memory[@memory[@pointer + 1]] = dir
				end
				step = 2
			when 4
				# p read(@memory[@pointer + 1], mode_first)
				r = read(@memory[@pointer + 1], mode_first)
				@pointer += 2
				return r
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
				return nil
			end
			
			@pointer += step
		end
	end
end

def display_screen

end

file = File.new("input.txt", "r")
line = file.gets
memory = line.split(',').map { |e| e.to_i }
file.close

index_to_char = ["#", ".", "O"]

class Cell 
	attr_accessor :left, :right, :coords, :parent, :scanned, :move, :burnt
	def initialize (coords, parent, move)
		@move = move
		@coords = coords
		@parent = parent
		@left = nil
		@right = nil
		@scanned = false
		@burnt = false
	end

	def add_child cell
		if @right.nil?
			@right = cell
		elsif @left.nil?
			@left = cell
		else
			p "ERROR"
			exit
		end
	end	
end

def get_next_coordinates (cell, move)
	case move
	when 1
		return {:x => cell.coords[:x], :y => cell.coords[:y] - 1}
	when 2
		return {:x => cell.coords[:x], :y => cell.coords[:y] + 1}
	when 3
		return {:x => cell.coords[:x] - 1, :y => cell.coords[:y]}
	when 4
		return {:x => cell.coords[:x] + 1, :y => cell.coords[:y]}
	end	
	exit
end

def get_opposite_move move
	case move
	when 1
		return 2
	when 2
		return 1
	when 3
		return 4
	when 4
		return 3
	end	
	return 0
end

@robot = Amp.new(memory)
init_position = {:x => 150, :y => 70}
current = Cell.new(init_position, nil, nil)
@grid = {}
i = 0
to_scan = [1,2,3,4]
@oxygen_cell = nil
loop do
	Curses.setpos(current.coords[:y], current.coords[:x])
	Curses.addstr("X")
	Curses.refresh
	i += 1
	# sleep 0 if i > 223
	to_scan.each { |move| 
		next if move == get_opposite_move(current.move)
		next_coordinates = get_next_coordinates(current, move)
		ret = @robot.run(move)
		if ret == 0 #wall, didn't move
			@grid[next_coordinates] = 0
		elsif ret == 1 or ret == 2 #empty or oxygen, moved, go back.
			if ret == 2
				i = 1 # one step from oxygen
				a = current.dup
				while a.parent != nil
					a = a.parent
					i += 1
				end
				Curses.setpos(0,0)
				Curses.addstr("Oxygen at #{i} steps from origin")
				@oxygen_cell = current.add_child Cell.new(next_coordinates, current, move)
			else
				current.add_child Cell.new(next_coordinates, current, move)
			end

			@grid[next_coordinates] = ret
			@robot.run(get_opposite_move(move))
		end
	}
	current.scanned = true
	@grid.each { |k,v| 
		Curses.setpos(k[:y], k[:x])
		Curses.addstr(index_to_char[v])
	 }
	Curses.setpos(current.coords[:y], current.coords[:x])
	Curses.addstr(".")
	Curses.refresh

	if !current.left.nil? and !current.left.scanned
		current = current.left
		@robot.run(current.move)
	elsif !current.right.nil? and !current.right.scanned
		current = current.right
		@robot.run(current.move)
	else
		if current.parent.nil?
			p done
		else
			loop do
				@robot.run(get_opposite_move(current.move))
				current = current.parent
				if current.nil?
					break
				end
				if !current.right.scanned
					current = current.right
					@robot.run(current.move)
					break
				end
			end
		end
	end
	break if current.nil?
end


# part 2

will_be_o = [@oxygen_cell]

i = -1
while will_be_o.size != 0 do
	p i
	will_be_o = will_be_o.map { |cell| 
		cell.burnt = true
		@grid[cell.coords] = 2
		[cell.parent, cell.left, cell.right].select {|cell| !
			cell.nil?
		}.select { |cell| !cell.burnt }
	}.flatten
	i += 1
	@grid.each { |k,v| 
		Curses.setpos(k[:y], k[:x])
		Curses.addstr(index_to_char[v])
	 }
	Curses.refresh
end

Curses.setpos(1,0)
Curses.addstr("need #{i} to oxygen all")
Curses.refresh

sleep 10