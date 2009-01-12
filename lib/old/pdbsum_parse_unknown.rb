$name = "/home/b/berger/dipl/ext_stor/unknown_function/SearchHeaders.pl.html"

IO.foreach( $name ) do |l|
	if l =~ /http:\/\/www\.ebi\.ac\.uk\/thornton-srv\/databases\/cgi-bin\/pdbsum\/GetPage\.pl\?pdbcode=(\d\w{3})/
		puts( $1 )
    end
end