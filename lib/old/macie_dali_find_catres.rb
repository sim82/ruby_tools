
require 'rubygems'
require 'fastercsv'


$macie_catres_name = "/home/b/berger/dipl/macie/cml/catres.csv"
$macie_dali_neighbor_name = "/home/b/berger/dipl/ext_stor/macie_dali/neighbors.csv"

$macie_catres = []

FasterCSV.foreach($macie_catres_name, {:col_sep => ",", :headers => true}) do |l|
	$macie_catres << l;
end


def load_mapping( macie_rep, its_rep )
	
	name = "/home/b/berger/dipl/ext_stor/macie_dali/calpha_mapping/#{macie_rep}_#{its_rep}.map"
	
	mapping = {}
	
	IO.foreach(name) do |l|
		if l =~ /\w_(\w+)\s+->\s(\w+)/
			
			if $2 != "NULL"
				mapping[$1] = $2;	
            end
			
        end
    end
	
	return mapping;
	
end

FasterCSV.foreach($macie_dali_neighbor_name, {:col_sep => "\t", :headers => true}) do |l|
	macie_rep = l["rep_macie"];
	its_rep = l["rep"];
	zscore = l["zscore"];
	its_pdb = l["its"]
	macie_pdb = l["macie"][0..3];
	ec = l["ec"]
	ec_macie = l["ec_macie"]
	
	mapping = load_mapping( macie_rep, its_rep );
	
	n_cat = 0;
	n_cat_map = 0;
	
	macieId = nil
	
	$macie_catres.each do |mc|
		#puts( "#{mc["pdbid"]} #{macie_pdb}");
		
		next if mc["pdbid"] != macie_pdb;
		
		res = mc["res"].upcase;
		macieId = mc["macieId"];
		
		map_res = mapping[res];
		
		map_res = "NONE" if map_res == nil;
		
		if res =~ /(\w{3})\d+/
			aa = $1;
        end
		
		if map_res =~ /\w_(\w{3})\d+/
			map_aa = $1;
        end
		
		puts( "aa: #{res} #{map_res}")
		
		if aa != nil && aa == map_aa
			n_cat_map += 1;
        end
		n_cat+=1;
	#	puts( "catres: #{macieId} #{macie_pdb} #{macie_rep} #{its_rep} #{its_pdb} #{zscore} #{res} -> #{map_res}")
		
    end
	
	puts( "#{n_cat == n_cat_map ? ">>>>" : ""}found #{macieId} #{macie_pdb} #{macie_rep} #{its_rep} #{its_pdb} #{ec_macie} #{ec} #{zscore}: #{n_cat_map}/#{n_cat}" )
	
end