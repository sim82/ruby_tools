#!/usr/bin/ruby

$stdin.each_line do |l|
	
	if( l =~ /<.+>/)
		next;
	end
	puts(l);
end