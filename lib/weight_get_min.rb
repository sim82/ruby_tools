mind = 10000;
minl = nil
$stdin.each_line do |l|
# 	if l =~ /\s([\d\.]+)$/
# 		d = $1.to_f
# 		#puts d
# 		if d <= mind
# 			mind = d
# 			minl = l
# 
# 			puts minl
# 		end
# 	end

# almost twice as fast:
	ls = l.split
	d = ls.last.to_f

	if d <= mind
		mind = d
		minl = l

		puts minl
	end

end


