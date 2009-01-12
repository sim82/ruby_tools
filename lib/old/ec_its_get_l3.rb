require 'csv'
require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'


def get_pdb_ids_by_ec( ec ) 
	ids = [];

	res = Net::HTTP.get( URI.parse( "http://www.ebi.ac.uk/thornton-srv/databases/cgi-bin/enzymes/GetPage.pl?ec_number=#{ec}"));

	#ress = res.body;
	res.each_line do |l|
		if( l =~ /\/thornton-srv\/databases\/cgi-bin\/pdbsum\/GetPage\.pl\?pdbcode=(.{4})/)
			#puts( $1 );
			
			ids << $1;
		end
	end
	
	return ids;
end


$name = ARGV[0]

l3 = {}
CSV.foreach($name) do |l|  
	#puts( l[2]);
	
	
	ec = l[2];
	
	if( ec =~ /((\d+)\.(\d+)\.(\d+))\.(\d+)/)
		ec3 = $1;
		l3[ec3] = 1;
	end
		
	
end


l3.each_key do |key|
	puts("#{key}:");

	l3f = File.open( "./ec_to_pdb3/#{key}", "w");
	
	IO.foreach( "./l3/#{key}") do |l|
		l.chomp!;
		puts( "  '#{l}'");
		
		l4f = File.open( "./ec_to_pdb/#{l}", "w");
		ids = get_pdb_ids_by_ec(l);
		
		ids.each do |id|
			puts( "    #{id}");
			l4f.puts(id);
			l3f.puts(id);
        end
		
		l4f.close();
    end
	l3f.close();
end