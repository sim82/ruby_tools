require 'rubygems'
require 'fastercsv'
require 'sqlite3'


$dali_rep_csv = "/home/b/berger/dipl/ext_stor/macie_dali/dali_rep.csv"
$dali_neighborhood = "/home/b/berger/dipl/ext_stor/its_hd/stat/dali_neighborhood.csv"
$dali_sq3_name = '/usr/local/storage/download/dali_idx.sq3'

$db = SQLite3::Database.new( $dali_sq3_name );



$rep_to_macie = {}

FasterCSV.foreach($dali_rep_csv, {:col_sep => ",", :headers => true}) do |l|
	id = l["id"];
	repid = l["rep"]
	
	next if repid == "X"
	
	if $rep_to_macie[repid] != nil
		#		puts( "duplicate: #{repid} #{$rep_to_macie[repid]} #{id}");
    else
		$rep_to_macie[repid] = id;
	end
	
	
end



def dali_get_rot_trans( dali_id_all ) 
	if dali_id_all =~ /(\d+)_(\d)/
		dali_id = $1;
		dali_dir = $2;
    else
		throw "cannot parse dali id: #{dali_id_all}";
	end
	
	if dali_dir == "0"
		matrix_name = "mb"
		transl_name ="ta"
	elsif dali_dir == "1"
		matrix_name = "ma"
		transl_name ="tb"
	else
		throw "cannot extract direction form dali_id #{dali_id_all}"
	end

	rotate = nil;
	translate = nil;
	
	$db.execute( "select #{matrix_name}, #{transl_name} from dali where seq = \"#{dali_id}\"") do |row|
		#puts( "#{row[0]}, #{row[1]}")

		rotate = row[0];
		translate = row[1];
	end

	if rotate == nil || translate == nil
		throw "cannot get rotation/translation for #{dali_seq}"
	end

	rots = rotate.split(/\s+/).join(",")
	transs = translate.split( /\s+/).join(",")
	
	
	return [rots,transs];
end


#puts("rep\tits\trep_macie\tmacie\tec\tec_macie\tkegg\tzscore\tecd" );



$pairs = {};
FasterCSV.foreach($dali_neighborhood, {:col_sep => "\t", :headers => true}) do |l|
	idNeighbor = l["id2"]
	idIts = l["id1"];
	
	zscore = l["zscore"]
	
	kegg1 = l["kegg1"]
	idRep = l["id_repr"]
	
	ec1 = l["ec1"]
	ec2 = l["ec2"]
	
	ecd = l["ecd"]
	
	dali_id_all = l["dali_id"];
	
	
	
	
	idMacie = $rep_to_macie[idNeighbor]
	
	
	(rot,trans) = dali_get_rot_trans(dali_id_all);
	
	if zscore.to_f < 10 
		next
    end
	
	indir = "/home/b/berger/dipl/ext_stor/macie_dali/pdb_macie_rep";
	outdir = "/home/b/berger/dipl/ext_stor/macie_dali/pdb_macie_rep_superpos";
	outdir_cam = "/home/b/berger/dipl/ext_stor/macie_dali/calpha_mapping";
	its_rep_dir = "/home/b/berger/dipl/ext_stor/macie_dali/pdb_its_rep"
	
	if idMacie != nil
		if !true
			puts( "#{idRep}\t#{idIts}\t#{idNeighbor}\t#{idMacie}\t#{ec1}\t#{ec2}\t#{kegg1}\t#{zscore}\t#{ecd}\t#{rot}\t#{trans}")
    
		else
				
			pair = "#{idNeighbor}_#{idRep}"
		
			if $pairs[pair] != nil
				next;
			end
			$pairs[pair] = 1;
		
			java = "java -cp `scripts/cp.sh` org.jcowboy.poj.algo.preparation.protonation.RotatePdb"
			java2 = "java -cp `scripts/cp.sh` org.jcowboy.poj.algo.preparation.protonation.CAlphaMapping"
			
			#puts( "#{java} #{indir}/#{idNeighbor[0..3]}.pdb #{outdir}/#{idNeighbor}_#{idRep}.pdb #{trans} #{rot}");
			
			
			puts( "#{java2} #{outdir}/#{idNeighbor}_#{idRep}.pdb #{its_rep_dir}/#{idRep[0..3]}.pdb > #{outdir_cam}/#{idNeighbor}_#{idRep}.map");
		end
	end
end
