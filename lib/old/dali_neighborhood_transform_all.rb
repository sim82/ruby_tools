# doku:
# Das skript nimmt zwei parameter: query pdb id und output-path prefix (optional)
# 
# Query id:
# pdbid + chain, wie in der dali-db ueblich (bei manchen entries fehlt die chain id)
# Die datei '/mnt/data/A/BIO-A/berger/dipl/ext_stor/dali/pdb90_ids.txt' entheilt eine
# liste mit allen moeglichen ids ('representanten' == pdb90)
#
# Ausgabe (auf stdout):
# transformations-daten, die man direkt als input-parameter fuer die java klasse
# 'org.jcowboy.poj.algo.preparation.protonation.RotatePdb' benutzen kann.
# 
# format der parameter: <input-file> <output-file> <vector> <matrix>
# input-file: pdb file des nachbarn (muss bereitgestellt werden). 
# output-file: nachbar-struktur superpositioniert auf query-struktur. Wird von RotatePdb
# erzeugt.
#
# mini tutorial:
# Beispiel: query fuer 1de5 (dali intern: 1de5A)
# > ruby /mnt/data/A/BIO-A/berger/dipl/src/NetbeansRuby/main/lib/dali_neighborhood_transform_all.rb 1de5A '/tmp'
# 
# output:
# =======
# /tmp/1de5.pdb /tmp/1de5A_1de5A.pdb 0.000,0.000,0.000 1.000,0.000,0.000,0.000,1.000,0.000,0.000,0.000,1.000
# /tmp/1dxi.pdb /tmp/1dxiA_1de5A.pdb -9.417,56.059,38.123 0.187,0.804,0.564,-0.682,-0.307,0.664,0.707,-0.509,0.491
# /tmp/1bxb.pdb /tmp/1bxbA_1de5A.pdb 82.977,-146.042,81.535 0.964,0.230,-0.136,0.265,-0.892,0.367,-0.037,-0.390,-0.920
# /tmp/1did.pdb /tmp/1didA_1de5A.pdb -19.610,-25.339,31.266 0.698,0.372,0.612,0.236,0.687,-0.687,-0.676,0.624,0.392
# /tmp/1a0e.pdb /tmp/1a0eA_1de5A.pdb 31.125,20.775,5.260 -0.194,-0.601,0.776,0.005,-0.791,-0.612,0.981,-0.114,0.15
# ...
# =======
#
# Beispiel: 1dxi auf 1de5 ueberlagern
# > cd /tmp
# > sh /mnt/data/A/BIO-A/berger/dipl/pdb/get_pdb.sh 1dxi
# > sh /mnt/data/A/BIO-A/berger/dipl/pdb/get_pdb.sh 1de5
# > cd /mnt/data/A/BIO-A/berger/workspace/chill
# > sh scripts/sge_java_runner2.sh org.jcowboy.poj.algo.preparation.protonation.RotatePdb /tmp/1dxi.pdb /tmp/1dxiA_1de5A.pdb -9.417,56.059,38.123 0.187,0.804,0.564,-0.682,-0.307,0.664,0.707,-0.509,0.491
# > cd /tmp
# > pymol 1de5.pdb 1dxiA_1de5A.pdb
#
#


require 'rubygems'
require 'fastercsv'
require 'sqlite3'


$dali_sq3_name = '/usr/local/storage/download/dali_idx.sq3'
$db = SQLite3::Database.new( $dali_sq3_name );

$pdb90 = "/mnt/data/A/BIO-A/berger/dipl/ext_stor/dali/pdb90_ids.txt"

$out_file = File.open("transform.txt", "w");

$pdb90_hash = {}
$pdb90c_hash = {}

IO.foreach($pdb90) do |l|
	l.chomp!
	
	$pdb90_hash[l[0..3]] = 1;
	$pdb90c_hash[l] = 1;
end

def get_neighborhood(id, zthresh)
	pair_to_highest_zscore = {};
	pair_to_highest_dali_id = {};
	
	$db.execute( "select seq, id1, id2, zscore from dali where (id1 = '#{id}') and zscore > #{zthresh} union select seq, id1, id2, zscore from dali where (id2 = '#{id}') and zscore > #{zthresh}") do |row|
#    $db.execute( "select seq, id1, id2, zscore from dali where (id1 = '#{id}') and zscore > #{zthresh}") do |row|
		# this query is slow
		#$db.execute( "select id1, id2, zscore from dali where (id1 = '#{id}' or id2 = '#{id}') and zscore > 15") do |row|
		#		id1 = row["id1"];
		
		id1 = row[1];
		id2 = row[2];
		
		seq = row[0];
		
		otherid = (id == id1) ? id2 : id1;
		
		dir = (id == id2) ? 0 : 1;
		
		# there are masses of entries in the dali db which involve non-pdb90 ids. 
        # it is not clear what those entries are for, or if they are correct. ignore them.
		next if not $pdb90c_hash.has_key?(otherid);
		
		#uid = get_pair_uid(id1, id2);
		
		zscore = row[3].to_f;
		
		old_zscore = pair_to_highest_zscore[otherid];
		if old_zscore == nil or old_zscore < zscore
			pair_to_highest_zscore[otherid] = zscore;
			pair_to_highest_dali_id[otherid] = "#{seq}_#{dir}";
        end
		
		#puts( "#{id1} #{id2} #{zscore}" );
		
		
    end
	
	
	
	kv = pair_to_highest_zscore.keys.map do |key| 
		[key,pair_to_highest_zscore[key],nil, pair_to_highest_dali_id[key]];
    end.sort do |a, b|
		# sort by zscore (descending)
		
		#if a[2] != b[2]
		#	a[2] <=> b[2]
        #else
		b[1] <=> a[1];
		#end
    end
	
	
	
	
	#	pair_to_highest_zscore.keys.sort.each do |key|
	#		puts( "#{key}: #{pair_to_highest_zscore[key]}");
	#    end
	
	
	#	kv.each do |p|
	#		puts( "#{p[0]} #{p[1]} #{p[2]}" );
	#    end
	
	return kv;
end







$query_id = ARGV[0]
$prefix = ARGV[1]

if $prefix != nil
	if not $prefix =~ /.*\/$/
		$prefix = "#{$prefix}/";
    end
else
	prefix = "";
end


# get neighborhood from the database
$zthresh = 0.0;
$ns = get_neighborhood($query_id, $zthresh );


# process list of neighbors
$ns.each do  |n|
	# each neighbor entry returned by get_neighbors consists of an array:
	
	# the id of the neighbor (pdbid + chain)
	other_id = n[0];
	
	# the 'dali id' which is an unique id of the dali database entry + flag (0 or 1) indicating the
	# 'direction' of the entry (there are two mappings per entry for the two possible superpositions)
	dali_id = n[3];
	
	
	if dali_id =~ /(\d+)_(\d)/
		dali_seq = $1;
		dir = $2;

		matrix_name = nil;
		transl_name = nil;

		# dali database quirk:
		# the matrix- and translation-columns for the different directions seem to be mixed up
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

		
		# get the rotation matrix and translation vector
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

		other_id_nochain = other_id[0..3]
		#$out_file.
		puts( "#{$prefix}#{other_id_nochain}.pdb #{$prefix}#{other_id}_#{$query_id}.pdb #{transs} #{rots}");

	end
	
end
$out_file.close;