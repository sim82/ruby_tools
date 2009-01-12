require 'rubygems'
require 'fastercsv'
require 'csv'

$stat_name = "/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/its_stat_tan_06_score_0.csv"

$dalilite_jobs_name = "/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/dalilite_jobs/jobs.txt"
$dalilite_result_dir = "/home/b/berger/dipl/ext_stor/its_hd/stat/dalilite_jobs/result"

jobids = {}
dalirep = {}

csv = CSV.open($dalilite_jobs_name, "r");

csv.each do |l|
	#puts( l[0]);
	
	jobids[l[0]] = l[4];
	dalirep[l[0]] = "#{l[2]}#{l[3]}"
end

csv.close();

$itsdock_out_csv = "/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.csv";

#csv = CSV.open( $itsdock_out_csv, "r", "\t" );

itsdock_pla = {}

FasterCSV.foreach($itsdock_out_csv, {:col_sep => "\t", :headers => true}) do |l|
	itsdock_pla[l["id"]] = l["pla"];
end

#csv.close()

def read_dalilite_matrix(filename)
	mx1 = "X"
	mx2 = "X"
	mx3 = "X"
	
	my1 = "X"
	my2 = "X"
	my3 = "X"
	
	mz1 = "X"
	mz2 = "X"
	mz3 = "X"
	
	tx = "X";
	ty = "X";
	tz = "X";
	
	
	
	IO.foreach(filename) do |line| 
#		puts(line);
		
		if line =~ /\|\s+(\S+)\s+(\S+)\s+(\S+)\s+\|.{3}\|\sx\s\|.{3}\|\s+(\S+)\s+\|/
			mx1 = $1;
			mx2 = $2;
			mx3 = $3;
			tx = $4;
        elsif line =~ /\|\s+(\S+)\s+(\S+)\s+(\S+)\s+\|\s\*\s\|\sy\s\|\s\+\s\|\s+(\S+)\s+\|/
			my1 = $1;
			my2 = $2;
			my3 = $3;
			ty = $4;
		elsif line =~ /\|\s+(\S+)\s+(\S+)\s+(\S+)\s+\|.{3}\|\sz\s\|.{3}\|\s+(\S+)\s+\|/
			mz1 = $1;
			mz2 = $2;
			mz3 = $3;
			tz = $4;
			break;
		end
    end
	
	
	return "#{mx1},#{mx2},#{mx3},#{my1},#{my2},#{my3},#{mz1},#{mz2},#{mz3}\t#{tx},#{ty},#{tz}";
end

#def get_docked_its_name(id)
#	
#	
#	csv_name = "/mnt/data/C/BIO-C/marialke/results/ITS_debug/#{id}/#{id}.csv";
#	
#	csv = CSV.open(csv_name, "r", "\t");
#	
#	#skip header
#	csv.shift;
#	
#	l = csv.shift;
#	
#	return l[8];
#end



puts( "in\tout\trotate\ttranslate")


csv = CSV.open($stat_name, "r");
first = true;
csv.each do |l|
	if( first )
		first = false;
		next;
    end
	
	#puts(l[0]);
	
	id = l[0];
	
	
	pdbid = nil;
	if id =~ /mol2_(\d\w{3})_/
		pdbid = $1;
    end
	
	jobid = jobids[pdbid];
	if jobid == nil
		next
    end
	matrix_name = "#{$dalilite_result_dir}/matrix_#{jobid}";
	matrix = read_dalilite_matrix(matrix_name);
	
	scpdb_prot = "/mnt/data/A/BIO-A/apostola/ch/cheminfo/admin/sc-pdb/proteins/#{pdbid}_prot_sansCof.mol2";
	scpdb_its = itsdock_pla[id];
	
	if scpdb_its == nil
		throw "bluuuurrrrrp"
    end
	outdir = "/home/b/berger/dipl/ext_stor/dali/its_dali_sup";
	#puts( "#{id}\t#{matrix}\t#{scpdb_its}");
	rep = dalirep[pdbid];
	
	puts( "#{scpdb_its}\t#{outdir}/#{id}_#{rep}_its.mol2\t#{matrix}");
	puts( "#{scpdb_prot}\t#{outdir}/#{id}_#{rep}_prot.mol2\t#{matrix}");
end