#!/bin/ruby
require 'chunky_png'

file = File.new("input.txt", "r")
line = file.gets
file.close

x = 25
y = 6
i = 0
layer_size = x * y
results = []
layers = []
while i * layer_size < line.size
	layer_map = {}
	layer = line[i*layer_size..(i+1)*layer_size-1]
	layers.push(layer)
	layer.each_char do |pixel|
		pixel = pixel.to_i
		# p pixel
		if  layer_map[pixel]
			layer_map[pixel] += 1
		else
			layer_map[pixel] = 1
		end
	end
	i += 1
	results.push(layer_map)
end
# min = results.min { |a, b| a[0] <=> b[0] }
# puts min[1] * min[2]

# part 2
final_image = []
nb_layers = line.size / layer_size
layer_size.times do |pixel_index|
	current_pixel = "2"
	nb_layers.times do |layer_count|
		current_pixel = layers[layer_count][pixel_index]
		if current_pixel != "2"
			final_image.push(current_pixel)
			break
		end
		if layer_count == nb_layers - 1
			final_image.push(current_pixel)
		end
	end
end

a = final_image.join('').scan /.{25}/ 
png = ChunkyPNG::Image.new(25, 6, ChunkyPNG::Color::TRANSPARENT)
a.each.with_index do |line, line_idx|
	line.each_char.with_index do |char, idx|
		png[idx, line_idx] = char == "1" ? "white" : "black"
	end
end
png.save('message.png', :interlace => true)