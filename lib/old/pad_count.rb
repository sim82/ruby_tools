$start = ARGV[0].to_i;
$stop = ARGV[1].to_i;
$pad = ARGV[2].to_i;



$start.upto($stop) do |n|
	out = n.to_s;
	
	while out.length < $pad
		out = "0#{out}";
    end
	
	puts( out );
end