

def read_rnf( name ) 
	m = {}
	
	File.open( name, "rb" ) do |f|
		f.each_line do |l|
			if l =~ /\d+\s+(\S+)\s(\S+)\s(\S+)/
				if $2 == "*NONE*"
					m[$1] = $1
				end
			end
		end
	
	end
	
	return m
end


inner_qs = read_rnf( ARGV[0] );
kill = ARGV[1] != nil

$stdin.each_line do |l|
	if l =~ /^XXXX\s+XXX\s+(\S+)/
		seq = $1;
	elsif l =~ /^0\s+0\s+(\S+)/
		seq = $1;
	elsif l =~ /^\S+\s+200_60.+\s(\S+)$/
		seq = $1
	elsif l =~ /^(\S+)/
		seq = $1;
	end
# 	puts( "seq: #{seq}" )
	if seq =~ /(.*)_\d\d/
		seq = $1
	end
	
	if kill or inner_qs[seq] != nil  
		puts(l)
	end
end