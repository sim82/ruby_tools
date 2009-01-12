$pid = ARGV[0]

bytes = 0;

`pmap #{$pid}`.each_line() do |l|
	
	sp = l.split(/\s+/);
	
	mapping = sp[5];
	
	
	if( mapping == "[anon]" || mapping == "[stack]" || mapping == "[heap]")
		puts( l);
		
		rss = sp[2];
		
		
		if( rss =~ /(\d+)K/)
			bytes += rss.to_i * 1024;
        end
		
    end
end


puts( "real: #{bytes/1024}K")
