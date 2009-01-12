require 'csv'
require 'soap/wsdlDriver'
require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'


$dalijobs_name = "/home/b/berger/dipl/ext_stor/its_hd/stat/dalilite_jobs/jobs.txt"

wsdl = "http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDaliLite.wsdl"


serv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver



csv = CSV.open( $dalijobs_name, "r" );
$result_dir = "/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/dalilite_jobs/result"
csv.each do |l|
	id = l[0];
	chain = l[1];
	repid = l[2];
	repchain = l[3];
	
	jobid = l[4];
	
	matrix_name = "#{$result_dir}/matrix_#{jobid}";
	
	if File.exist?(matrix_name)
		puts( "skip: #{id},#{chain},#{repid},#{repchain}")
		next
    end
	
	stat = serv.checkStatus(jobid);
	
	puts( "#{id},#{chain},#{repid},#{repchain} stat: #{jobid} #{stat}")
	
	if stat == "DONE"
		res = Net::HTTP.get( URI.parse( "http://www.ebi.ac.uk/cgi-bin/jobresults/dalilite/#{jobid}/matrix.txt"));
		
		File.open(matrix_name,"w") do |f|
			f.puts(res);
        end
		
		res = Net::HTTP.get( URI.parse( "http://www.ebi.ac.uk/cgi-bin/jobresults/dalilite/#{jobid}/aln.html"));
		
		File.open("#{$result_dir}/aln_#{jobid}.html","w") do |f|
			f.puts(res);
        end
		
		res = Net::HTTP.get( URI.parse( "http://www.ebi.ac.uk/cgi-bin/jobresults/dalilite/#{jobid}/index.html"));
		
		File.open("#{$result_dir}/index_#{jobid}.html","w") do |f|
			f.puts(res);
        end
		
    end
	
end