$name = ARGV[0]


IO.foreach($name) do |l|
	if ( l =~ /^ID\s+(\d+\.\d+\.\d+\.\d+)/)
		puts( $1 );
    end
end