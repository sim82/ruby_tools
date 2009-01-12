require 'rubygems'
require 'fastercsv'
require 'sqlite3'

$name = "/home/b/berger/dipl/ext_stor/its_hd/stat/dali_neighborhood_ecd1.csv"
$neigh_import_dir = "/home/b/berger/dipl/ext_stor/dali/neighborhood_import"


$neighbor_ids = {}

$dali_sq3_name = '/usr/local/storage/download/dali_idx.sq3'
$db = SQLite3::Database.new( $dali_sq3_name );

$f_rot = File.open("/home/b/berger/dipl/ext_stor/dali/neighborhood_import/rotate.csv", "w");

$f_rot.puts( "in\tout\trotate\ttranslate")



FasterCSV.foreach($name, {:col_sep => "\t", :headers => true}) do |l|
	id1 = l["id1"];
	id2 = l["id2"];
	
	id_repr = l["id_repr"]
	
	id = id2

	if id2 =~ /^(\d\w{3})/
		id = $1
	end
	
	
	puts(id);
	
	
	
	
	
	# pdbids may occure more than once. we only need to import them once

	$neighbor_ids[id] = 1;

	dali_id = l["dali_id"];

	if dali_id =~ /(\d+)_(\d)/
		dali_seq = $1;
		dir = $2;

		matrix_name = nil;
		transl_name = nil;

		if dir == "0"
			matrix_name = "mb"
			transl_name ="ta"
		elsif dir == "1"
			matrix_name = "ma"
			transl_name ="tb"
		else
			throw "cannot extract direction form dali_id #{dali_id}"
		end
		#puts( dali_id )

		rotate = nil
		translate = nil
		$db.execute( "select #{matrix_name}, #{transl_name} from dali where seq = \"#{dali_seq}\"") do |row|
			#puts( "#{row[0]}, #{row[1]}")

			rotate = row[0];
			translate = row[1];
		end

		if rotate == nil || translate == nil
			throw "cannot get rotation/translation for #{dali_seq}"
		end

		rots = rotate.split(/\s+/).join(",")
		transs = translate.split( /\s+/).join(",")

		in_name = "#{$neigh_import_dir}/out/output_files/#{id}_pocket.mol2"

		
		out_name = "#{$neigh_import_dir}/superpos/#{id}_#{id_repr}.mol2";
		
		#if File.exist?( out_name )
		puts( "#{in_name}\t#{out_name}\t#{rots}\t#{transs}");
		#end

	end
	
end

$f_imp = File.open( "/home/b/berger/dipl/ext_stor/dali/neighborhood_import/import_pdb.csv", "w")
$f_imp_new = File.open( "/home/b/berger/dipl/ext_stor/dali/neighborhood_import/import_pdb_new.csv", "w")

$f_imp.puts( "protein\tligand" );
$f_imp_new.puts( "protein\tligand" );

$f_ids = File.open( "dali_neighbor_pdbids.txt", "w")



$neighbor_ids.keys.sort.each do |key|
	


	$f_ids.puts( key );
	
	$f_imp.puts( "/home/b/berger/dipl/ext_stor/dali/neighborhood_import/#{key}.pdb\tbla,0.0,0.0,0.0")
	if ! File.exist?( "#{$neigh_import_dir}/out/output_files/#{key}_pocket.mol2.gz" )
		$f_imp_new.puts( "/home/b/berger/dipl/ext_stor/dali/neighborhood_import/#{key}.pdb\tbla,0.0,0.0,0.0")
	end
	
	
end



$f_imp.close
$f_imp_new.close
$f_ids.close
$f_rot.close