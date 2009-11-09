STDIN.each_line do |l|
	if l =~ /Tree (\d+) Likelihood (\S+)/
		puts( "#{$1} #{$2}" )
	end
end