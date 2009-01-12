require 'rubygems'
require 'fastercsv'


$out_csv = "/home/b/berger/dipl/ext_stor/its_hd/propka_fit2/out.csv"

$rid_ec_name = "/home/b/berger/dipl/ext_stor/kegg/rid.csv"
$rid_ec_map = {}

FasterCSV.foreach( $rid_ec_name, {:col_sep => ",", :headers => true}) do |l|
	$rid_ec_map[l["rid"]] = l["ec"];
end


$ec_filter = ["1.1.1", "1.3.1", "1.3.99", "1.1.99", "1.17.4", "1.7.3", "1.1.3", "1.4.3", "1.21.3", "1.1.99", "1.14.12", "1.2.1"]
	

puts( "id\tpla\ttem\tprot\tprot_score\ttan\tkegg\tec\tpdb")

FasterCSV.foreach($out_csv, {:col_sep => "\t", :headers => true}) do |l|
	id = l["id"];
	pla = l["pla"];
	tem = l["tem"];
	prot = l["prot"];
	prot_score = l["prot_score"];
	tan = l["tan"];
	
	
	if id =~ /(R\d{5})_.+mol2_(\d\w{3})_/
		keggid = $1
		pdbid = $2
    else
		throw "cannot parse its name: #{id}"
	end
	
	ec = $rid_ec_map[keggid];

		
	if ec == nil
		ec = "X.X.X.X"
    end
	
	ignore = false
	
	$ec_filter.each do |f|
		if ec.index(f) == 0
		
			ignore = true;
			break;
        end
    end
	
	if ! ignore 
		puts( "#{id}\t#{pla}\t#{tem}\t#{prot}\t#{prot_score}\t#{tan}\t#{keggid}\t#{ec}\t#{pdbid}")
	end
end