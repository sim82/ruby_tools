require 'csv'
require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'



def dali_query( id )
	res = Net::HTTP.get( URI.parse( "http://ekhidna.biocenter.helsinki.fi/dali/daliquery?find=#{id}"));
	#puts( "id: #{id}" );
	
	rep = nil;
	
	res.each_line do |l|
		if( l=~ /http:\/\/ekhidna\.biocenter\.helsinki\.fi\/dali\/downloads\/HTML\/(\d\w+).html/)
			rep = $1;
			
			#puts( "repres: #{rep}" )
			break;
        end
    end
	
	return rep;
end


$name = ARGV[0]

done = {}

puts("id,rep")
IO.foreach($name) do |id|
	id.chomp!;
	
	rep = dali_query(id);
	
	if id.length == 5
			
		shortid = id[0..3];
	else
		shortid = id;
	end
	
	
	if rep == nil 
		#puts( "retry #{id2}" );
		
		if done[shortid] == nil 
			rep = dali_query(shortid);
        end
		
		

    end

	if rep == nil
		rep = "X"
	else
		done[shortid] = 1;
	end
	
	puts("#{id},#{rep}")
	
end