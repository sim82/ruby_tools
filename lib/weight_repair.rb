last_weights = nil

$stdin.each_line do |l|
	if l =~ /^(\d+)(\s.+\s)([\d\.]+)$/
		n = $1.to_i
		w = $2
		d = $3.to_f
		#puts "#{n} #{d}"
		if last_weights != nil
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


