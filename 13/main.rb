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
      @memory[0] = 2
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

	def run (next_move)
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
				if @ret.nil? or @ret.size == 3 
				 	# restart
				 	@ret = [r]
				elsif @ret.size == 2
					# 3 instructions, return
				 	@ret.push(r)
				 	@pointer += 2
				 	return @ret
				 else
				 	@ret.push(r)
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

index_to_char = [" ", "#", "▂", "_", "O"]
ball_x = 22
bar_x = 20
next_move = 1
game = Amp.new(memory)
i = 0
while true
	if ball_x == bar_x
		next_move = 0 
	else
		next_move = ball_x > bar_x ? 1 : -1
	end
	ret = game.run(next_move)
	break if ret.nil?
	x, y, d = ret
	if d == 4 #ball pos
		ball_x = x
	end
	if d == 3 #paddle pos
		bar_x = x
	end

	if x == -1 and y == 0
		Curses.setpos(0, 0)
		# Curses.addstr("padde:#{bar_x.to_s}, ball: #{ball_x}, next_move: #{next_move} ")
		Curses.addstr(d.to_s)
	else
		Curses.setpos(y+1, x)
		Curses.addstr(index_to_char[d])
	end
	Curses.refresh
	i += 1
	sleep 0.001 if i > 1040
end
sleep 10
# Curses.close_screen