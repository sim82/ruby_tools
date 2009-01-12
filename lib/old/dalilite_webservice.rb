require 'csv'

require 'soap/wsdlDriver'
$wsdl = "http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDaliLite.wsdl"


$serv = SOAP::WSDLDriverFactory.new($wsdl).create_rpc_driver


$its_pdblist = "/home/b/berger/dipl/ext_stor/its_hd/stat/pdb_to_dali_representant.csv"

csv = CSV.open( $its_pdblist, "r");

dalijobs = File.new( "/home/b/berger/dipl/ext_stor/its_hd/stat/dalilite_jobs/jobs.txt", "a");

$oldjobs_name = "/home/b/berger/dipl/ext_stor/its_hd/stat/dalilite_jobs/jobs.txt_old"

$oldjobs = {}

if File.exist?($oldjobs_name)
	IO.foreach($oldjobs_name) do |line|
		if line =~ /(.*,.*,.*,.*),/
			$oldjobs[$1] = $1;
        end 
    end
end

dalijobs = File.new( "/home/b/berger/dipl/ext_stor/its_hd/stat/dalilite_jobs/jobs.txt", "a");


first = true;
csv.each do |l|
	if first 
		first = false;
		next;
    end
	
	id = l[0];
	chain = l[1];
	rep = l[2];
	
	if( rep == "XXXXX")
		puts( "ignore: XXXXX")
		next;
    end
	
	repid = nil;
	repchain = nil;
	if( rep =~ /(\d\w{3})(\w)/)
		repid = $1;
		repchain = $2;
    else
		repid = rep;
	end
	
	if id == nil || repid == nil
		throw "id == nil || repid == nil";
    end
	

	if( id == repid )
		puts( "same id. ignore")
		next;
    end
	
	myjobkey = "#{id},#{chain},#{repid},#{repchain}";
	
	if( $oldjobs.has_key?(myjobkey))
		puts( "ignoring old job: #{myjobkey}")
		next;
    end
	
		
	puts( "#{id} #{chain} #{repid} #{repchain}")
	params = {};


	params['async'] = true;
	params['email'] = "berger@cip.ifi.lmu.de"

	params['sequence1'] = repid
	
	if repchain != nil
		params['chainid1'] = repchain;
	end

	params['sequence2'] = id
	
	if chain != nil 
		params['chainid2'] = chain
	end

	begin
		pretend = !true
		
		
		puts( "run: #{params}")
		
		
		
		if !pretend
		
			jobid = $serv.runDaliLite( params );

			puts( jobid );
			dalijobs.puts( "#{id},#{chain},#{repid},#{repchain},#{jobid}" );
			dalijobs.flush
		end
	rescue Exception => e
		puts( ">>>>>>>>>> rescue: error occured: #{e}");
	end
end

dalijobs.close();



#throw "blub";
#
#
#
#
#
#throw "blub"
#
#
#
#
#
#puts( "poll: #{jobid}" );
#
#results = serv.getResults(jobid);
#
#result = nil;
#
#results.each do |r|
#
#	
#	if r.type == "tooloutput"
#		result = r;
#		break;
#	end
#		
#	
#end
#
#puts(result.type);
#puts(result.ext);
#
#
#while true
#	sleep(5);
#	
#	stat = serv.checkStatus(jobid);
#	
#	puts( "status: #{stat}");
#	
#	if stat == "DONE"
#		break;
#    end
#end
#res = serv.poll(jobid,result)
#
#puts(res);