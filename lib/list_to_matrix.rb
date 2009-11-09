xmin = 10000000
xmax = 0

ymin = 10000000
ymax = 0

data = {}

STDIN.each_line do |l|
	
	
	s = l.split

	x = s[0].to_i
	y = s[1].to_i

	d = s[3].to_f

	xmin = [xmin, x].min
	xmax = [xmax, x].max

	ymin = [ymin, y].min
	ymax = [ymax, y].max

	data["#{x}_#{y}"] = d

end

ymin.upto(ymax) do |y|
	line = ""
	xmin.upto(xmax) do |x|
		d = data["#{x}_#{y}"]
	
		if d == nil
			d = -1
		end



		puts d

	end
	
	puts "\n"
end