$name = ARGV[0];

l3h = {};

IO.foreach( $name ) do |l|
	if( l =~ /((\d+)\.(\d+)\.(\d+))\.(\d+)/ )
		puts( $1 );
	
		l3 = $1;
		if( l3h[l3] == nil )
			l3h[l3] = [l];
        else 
			l3h[l3] << l;
		end
		
    end
end


l3h.each_pair do |key, value|
	
	f = File.new(key, "w");
	value.each do |v|
		puts( "#{key}: #{v}");
		
		f.puts(v);
    end
	f.close();
end