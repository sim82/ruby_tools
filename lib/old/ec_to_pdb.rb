require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'

$ec = ARGV[0];


res = Net::HTTP.get( URI.parse( "http://www.ebi.ac.uk/thornton-srv/databases/cgi-bin/enzymes/GetPage.pl?ec_number=#{$ec}"));

#ress = res.body;
res.each_line do |l|
	if( l =~ /\/thornton-srv\/databases\/cgi-bin\/pdbsum\/GetPage\.pl\?pdbcode=(.{4})/)
		puts( $1 );
	end
end
