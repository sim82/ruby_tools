require 'soap/wsdlDriver'
wsdl = "http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDaliLite.wsdl"


serv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver



params = {};


params['async'] = true;
params['email'] = "berger@cip.ifi.lmu.de"

params['sequence1'] = "1dcn"
params['chainid1'] = "D"

params['sequence2'] = "1u15"
params['chainid2'] = "D"


throw "blub"


jobid = serv.runDaliLite( params );


puts( "poll: #{jobid}" );

results = serv.getResults(jobid);

result = nil;

results.each do |r|

	
	if r.type == "tooloutput"
		result = r;
		break;
	end
		
	
end

puts(result.type);
puts(result.ext);


while true
	sleep(5);
	
	stat = serv.checkStatus(jobid);
	
	puts( "status: #{stat}");
	
	if stat == "DONE"
		break;
    end
end
res = serv.poll(jobid,result)

puts(res);