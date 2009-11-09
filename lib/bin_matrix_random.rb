nlines = ARGV[0].to_i
ncols = ARGV[1].to_i



1.upto( nlines ) do |i|
	line = ""
	1.upto(ncols) do |j|
		line += rand(2).to_s

	end

	puts line
end