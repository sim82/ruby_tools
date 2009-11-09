mind = 10000;
minl = nil

last_weights = nil

$stdin.each_line do |l|
	if l =~ /^(\d+)(\s.+\s)([\d\.]+)$/
		n = $1.to_i
		w = $2
		d = $3.to_f
		#puts "#{n} #{d}"
		if d <= mind and last_weights != nil
			mind = d
			minl = l

			#puts minl
			puts "#{n}#{last_weights}#{d}"
		end

		last_weights = w
	end

# almost twice as fast:
# 	ls = l.split
# 	d = ls.last.to_f
# 
# 	if d <= mind
# 		mind = d
# 		minl = l
# 
# 		puts minl
# 	end

end


