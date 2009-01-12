require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'

if( ARGV[0] == nil || ARGV[1] == nil || ARGV[2] == nil ) then
	raise "missing argument. usage: prog <pdbfile> <out pkafile> <out new pdb>";
end



$pdbname = ARGV[0];
$outpka = ARGV[1];
$outpdb = ARGV[2];

module Multipart
  # From: http://deftcode.com/code/flickr_upload/multipartpost.rb
  ## Helper class to prepare an HTTP POST request with a file upload
  ## Mostly taken from
  #http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/113774
  ### WAS:
  ## Anything that's broken and wrong probably the fault of Bill Stilwell
  ##(bill@marginalia.org)
  ### NOW:
  ## Everything wrong is due to keith@oreilly.com
  

  class Param
    attr_accessor :k, :v
    def initialize( k, v )
      @k = k
      @v = v
    end

    def to_multipart
      #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"\r\n\r\n#{v}\r\n"
      # Don't escape mine...
      return "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
    end
  end

  class FileParam
    attr_accessor :k, :filename, :content
    def initialize( k, filename, content )
      @k = k
      @filename = filename
      @content = content
    end

    def to_multipart
      #return "Content-Disposition: form-data; name=\"#{CGI::escape(k)}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: #{MIME::Types.type_for(@filename)}\r\n\r\n" + content + "\r\n "
      # Don't escape mine
      return "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + "Content-Type: application/x-fuckup-language\r\n\r\n" + content + "\r\n"
	#return "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{filename}\"\r\n" + "Content-Transfer-Encoding: binary\r\n" + content + "\r\n"
    end
  end
  class MultipartPost
    BOUNDARY = '~~~~~~~~~~~!'
    HEADER = {"Content-type" => "multipart/form-data; boundary=" + BOUNDARY + " "}

    def prepare_query (params)
      fp = []
      params.each {|k,v|
        if v.respond_to?(:read)
          fp.push(FileParam.new(k, v.path, v.read))
        else
          fp.push(Param.new(k,v))
        end
      }
      query = fp.collect {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
      return query, HEADER
    end
  end  
end


def self.post_form(url, query, headers)
	Net::HTTP.start(url.host, url.port) {|con|
		con.read_timeout = TIMEOUT_SECONDS
		begin
			return con.post(url.path, query, headers)
		rescue => e
			puts "POSTING Failed #{e}... #{Time.now}"
		end
	}
end 

# my server expects the params of the POST to
# use the rails-like "blah[bar]" syntax, and I
# need to send two things other than the file
# itself. These are stored in the params Hash
params = Hash.new

# Open the actually file I want to send
file = File.open($pdbname, "rb")

# set the params to meaningful values

propka2 = false;



if( propka2 ) 
	soutdir = "energy";
	params["ENERGY"] = "true";
else
	soutdir = "pka";
end	

params["TEXTCONTROL"] = "UPLOAD"
params["PDB"] = file

# make a MultipartPost
mp = Multipart::MultipartPost.new

# Get both the headers and the query ready,
# given the new MultipartPost and the params
# Hash
query, headers = mp.prepare_query(params)

# done with file now
file.close

# Make sure the URL is useable
url = URI.parse('http://propka.ki.ku.dk/~drogers/cgi-bin/propka-dmr-2.0.py')
TIMEOUT_SECONDS=5;
# Do the actual POST, given the right inputs
res = post_form(url, query, headers)

# res holds the response to the POST
case res
	when Net::HTTPSuccess
		puts "Hooray"
	when Net::HTTPInternalServerError
		raise "Server blew up"
	else
		raise "Unknown error #{res}: #{res.inspect}"
end

#puts "query:\n#{query}";
#puts "headers:\n#{headers}";

puts( res );


ress = res.body;
	
while( ress =~ /\<meta http-equiv=\"Refresh\" content=\"([0-9]+); url=\/~drogers\/#{soutdir}\/(.+\.html)\"/ )
	
	time = $1.to_f
	name = $2;

	
	
	puts( "waiting ... #{time} '#{name}'" );
	sleep time;
	
	
	
	ress = Net::HTTP.get( URI.parse("http://propka.ki.ku.dk/~drogers/#{soutdir}/#{name}" ));
	
	if( not name =~ /-tmp\.html/ ) then
		puts( "got result" );
		break;
	end
end


puts( ress );

if( ress =~ /<p><a href=\"\/~drogers\/#{soutdir}\/(.*\.pka)\">Results<\/a><\/p>/ ) then
	name = $1;

	r2 = Net::HTTP.get( URI.parse("http://propka.ki.ku.dk/~drogers/#{soutdir}/#{name}" ));
	
	
	File.open( $outpka, "w" ) do |h|
		h.write(r2);
	end
else 
	raise "could not find URL of pka file in result";
end
# File.open( "html_1.0/#{name}.html", "w" ) do |h|
# 	h.write(ress);
# end

if( ress =~ /<p><a href=\"\/~drogers\/#{soutdir}\/(new_.*\.pdb)\">PROPKA 2\.0 Input<\/a><\/p>/ ) then
	name = $1;

	r2 = Net::HTTP.get( URI.parse("http://propka.ki.ku.dk/~drogers/#{soutdir}/#{name}" ));
	
	
	File.open( $outpdb, "w" ) do |h|
		h.write(r2);
	end
else 
	raise "could not find URL of new_pdb file in result";
end
	
