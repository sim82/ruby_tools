require 'rubygems'
require 'fastercsv'
require 'net/http'
require 'cgi'

$macie_catres = "/home/b/berger/dipl/ext_stor/macie_dali/dali_rep.csv"




FasterCSV.foreach($macie_catres, {:col_sep => ",", :headers => true}) do |l|
	macie_idc = l["id"];
	
	rep_idc = l["rep"];
	
	if rep_idc == "X"
		puts("ignore");
		next;
    end
	
	puts( "#{macie_idc} #{rep_idc}");
	
	if macie_idc =~ /(\d\w{3})(\w)/
		macie_id = $1;
		macie_chain = $2;
    else
		throw( "cannot get id and chain: #{macie_idc}");
	end
	
	if rep_idc =~ /(\d\w{3})(\w)/
		rep_id = $1;
		rep_chain = $2;
    elsif rep_idc =~ /(\d\w{3})/
		rep_id = $1;
		rep_chain = macie_chain;
	else
		throw( "cannot get pdb id from: #{rep_idc}");
	end
	
	macie_url = "http://www.rcsb.org/pdb/download/downloadFile.do?fileFormat=fastachain&compression=NO&structureId=#{macie_id}&chainId=#{macie_chain}";

	
	puts( "download: #{macie_url}");
	res = Net::HTTP.get( URI.parse( macie_url ));
	File.open( "fasta_macie/#{macie_idc}.fa", "w") do |f|
		f.puts(res);
    end

	
	
	rep_url = "http://www.rcsb.org/pdb/download/downloadFile.do?fileFormat=fastachain&compression=NO&structureId=#{rep_id}&chainId=#{rep_chain}";
	puts( "download: #{rep_url}");
	
	res = Net::HTTP.get( URI.parse( rep_url ));
	File.open( "fasta_rep/#{rep_idc}.fa", "w") do |f|
		f.puts(res);
    end
	
end

