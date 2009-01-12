if( ARGV[1] == nil ) then
	puts "wrong number of arguments.\nusage : subset.rb <infile> <numsets>";
	exit(-1);
end

$filename = ARGV[0];
$numsets = ARGV[1];

lines = File.readlines( $filename );

# generate random permutation over input lines
0.upto(lines.length - 1) do |i|
	tmp = lines[i];
	r = rand( lines.length )

	lines[i] = lines[r];
	lines[r] = tmp;
end

out = [];
j = 0;
i = 0;

# sample <$numsets> nearly equally sized subsets from permutation
while(true) do 
	if( i >= ((j+1) / $numsets.to_f) * lines.length) then
		out.sort!;
		File.open( "set#{j}.txt", "w" ) do |h|
			out.each do |o|
				h.puts( o );
			end	
		end
		
		j = j + 1;
		out = [];
	end
	
	break if i == lines.length;
	out << lines[i];
	i = i + 1;
end





