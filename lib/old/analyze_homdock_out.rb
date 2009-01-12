require 'rubygems'
require 'fastercsv'




$processed_dock_out_name = "/home/b/berger/dipl/ext_stor/its_hd/stat/its_dock_out_proc.csv"


$ec_hash = {}
$ec3_hash = {}
$pdb_hash = {}

$ec_filter = ["1.1.1", "1.3.1", "1.3.99", "1.1.99", "1.17.4", "1.7.3", "1.1.3", "1.4.3", "1.21.3", "1.1.99", "1.14.12", "1.2.1"]
	
$n_tan_06 = 0;
$n = 0;
FasterCSV.foreach($processed_dock_out_name, {:col_sep => "\t", :headers => true}) do |l|
	tan = l["tan"].to_f
	score = l["prot_score"].to_f
	ec = l["ec"];
	pdb = l["pdb"];
	
	ignore = false
	
	$ec_filter.each do |f|
		if ec.index(f) == 0
		
			ignore = true;
			break;
        end
    end
	
	next if ignore;
	
	if tan > 0.6 && score < 0
		$n_tan_06 += 1;
		ec3 = nil
		if ec =~ /(\d+\.\d+\.\d+)\.\d+/
			ec3 = $1;
		else
			ec3 = "X.X.X"
		end
	
		#	puts( "#{ec} #{ec3}")
		puts( "#{pdb}")
		$ec_hash[ec] = 1;
		$ec3_hash[ec3] = 1;
		$pdb_hash[pdb] = 1;
    end
	$n += 1;
	
	
	
 	
end


puts( "tan 0.6: #{$n_tan_06} of #{$n}");

puts( "uniq ec: #{$ec_hash.size}, ec3: #{$ec3_hash.length}");
puts( "uniq pdb: #{$pdb_hash.size}");