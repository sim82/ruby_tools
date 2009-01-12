$file = ARGV[0];



IO.foreach( $file ) do |l|
	#puts( l );
	
	if( l =~ /explore\.do\?structureId\=(.{4})/)
		puts( "#{$1}");
    end
end