$inname = ARGV[0];

IO.foreach($inname) { |line|

  if( line =~ /^ATOM/)
	if( line[77,1] != "H" )
	  puts(line);
    end
  else
	puts( line );
  end
	
  
  
  
}