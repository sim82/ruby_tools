first = true

nrow = nil
ncol = nil

colcount = []
lrl = []
line = 0
STDIN.each_line do |l|
	line += 1
	if first
 		if l =~ /(\d+)\s+(\d+)/
			nrow = $1.to_i
			ncol = $2.to_i

			0.upto( ncol - 1 ) do |i|
				colcount[i] = 0
				lrl[i] = -1
			end
		end

		first = false
		next

	end


	ls = l.split()
	name = ls[0]
	seq = ls[1]
	
	if( seq.length != ncol ) 
		throw "bad col number: #{seq.length} vs #{ncol}";
	end

	seq.upcase!

	0.upto( ncol - 1 ) do |i|
		c = seq[i]
# 		puts c
		

		if c != 45 and c != 63
			colcount[i]+=1
			lrl[i] = line
# 			if c != 65 and c != 57 and c != 71 and c != 84 and c != 85
# 				puts c
# 				puts seq
# 			end
		end
	end

end

# puts colcount.join( " " )

colcount.each_index do |i|
 	print "#{colcount[i]}(#{lrl[i]}) "
end