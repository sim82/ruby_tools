require 'rubygems'
require 'fastercsv'
require 'csv'
require 'builder'

require 'sqlite3'

$its_its_table = ARGV[0];
$out_all_name = ARGV[1];
$out_best_name = ARGV[2];



if ARGV.length < 3
	throw "missing arguments"
end








$dali_sq3_name = '/usr/local/storage/download/dali_idx.sq3'
$its_its_sq3_name = '/usr/local/storage/its_its/its_its.sq3'
$its_its_fingerprint_sq3_name = '/usr/local/storage/its_its/its_its_fingerprint.sq3'


$kegg_ec_name = "/home/b/berger/dipl/ext_stor/kegg/reaction"
$ec_mapping_name = '/home/b/berger/dipl/ext_stor/pdb_ec_mapping.txt'
$pdb90 = "/home/b/berger/dipl/ext_stor/dali/pdb90_ids.txt"

$db_ii = SQLite3::Database.new( $its_its_sq3_name );
$db_ii_fp = SQLite3::Database.new( $its_its_fingerprint_sq3_name );

$db_dali = SQLite3::Database.new( $dali_sq3_name );


#$pdb_to_dalirepr = {}
#
#FasterCSV.foreach($pdb_dali_repr_name, {:col_sep => ",", :headers => true}) do |l|
#	id = l["id"];
#	repid = l["repid"];
#	
#	$pdb_to_dalirepr[id] = repid;
#	
#end


$pdb90_hash = {}
$pdb90c_hash = {}

IO.foreach($pdb90) do |l|
	l.chomp!
	
	$pdb90_hash[l[0..3]] = 1;
	$pdb90c_hash[l] = 1;
end


#############################################
# ec -> kegg rid
#############################################
$ec_kegg = {}

begin
	rid = nil
	ecl = [];

	nl = -1;
	IO.foreach( $kegg_ec_name ) do |line|
		nl+=1;
		if line =~ /ENTRY\s+(R\d{5})/
			rid = $1;
        elsif line =~ /ENZYME\s+(\d+\.\d+\.\d+\.\d+\s*)+/
			ecl = $1.split(/\s+/);
		elsif line =~ /\/\/\//
			if rid == nil 
				throw "no rid in kegg reaction entry (line #{nl})";
            end
			
			
			
			ecl.each do |ec|
				$ec_kegg[ec] = rid;
			end
			
			#$kegg_ec[rid] = ecl;
			
			rid = nil;
			ecl = [];
		end
		
		
    end

end


###########################################3
# pdb -> ec
############################################

$pdb_ec = {};
$pdbc_ec = {};

cLine = -1;

IO.foreach( $ec_mapping_name ) do |line|
	cLine+=1;

	next if cLine < 2;
	
	if line =~ /(\d\w{3})\s*\|\s+(\w)\s+\|.+\|.+\|.+\|\s+(\S+)/
		id = $1;
		chain = $2;
		ec = $3;
		
		#puts( "'#{id}' '#{chain}' '#{ec}'");
		
		$pdb_ec[id] = ec;
		$pdbc_ec["#{id}#{chain}"] = ec;
    end
	
end

def pdb_to_ec( id )
	ec = nil;
	
	if id.length == 4
		ec = $pdb_ec[id];
    elsif id.length == 5;
		ec = $pdbc_ec[id];
	else
		throw "cannot parse pdbid: #{id}";
	end
	
	return ec != nil ? ec : "x.x.x.x";
	
end



def get_neighborhood(id, zthresh)
	pair_to_highest_score = {};
	pair_to_highest_dali_id = {};
	
	
	
	$db_dali.execute( "select seq, id1, id2, zscore, ident from dali where (id1 = '#{id}') and zscore > #{zthresh} union select seq, id1, id2, zscore, ident from dali where (id2 = '#{id}') and zscore > #{zthresh}") do |row|
		# this query is slow
		#$db.execute( "select id1, id2, zscore from dali where (id1 = '#{id}' or id2 = '#{id}') and zscore > 15") do |row|
		#		id1 = row["id1"];
		
		id1 = row[1];
		id2 = row[2];
		
		id1p = id1[0..3];
		id2p = id2[0..3];

		
		if( id1p != id2p && $pdb90_hash[id1p] != nil && $pdb90_hash[id2p] != nil)
		
			seq = row[0];

			otherid = (id == id1) ? id2 : id1;

			dir = (id == id2) ? 0 : 1;

			#uid = get_pair_uid(id1, id2);

			zscore = row[3].to_f;

			ident = row[4].to_f;
			
			score = nil
			
			if true
				score = zscore
            else
				score = ident
			end
			
			old_score = pair_to_highest_score[otherid];
			if old_score == nil or old_score < score
				pair_to_highest_score[otherid] = score;
				pair_to_highest_dali_id[otherid] = "#{seq}_#{dir}";
			end
			
		end
		#puts( "#{id1} #{id2} #{zscore}" );
		
		
    end
	
	kv = pair_to_highest_score.keys.map do |key| 
		[key,pair_to_highest_score[key],pdb_to_ec(key), pair_to_highest_dali_id[key]];
    end.sort do |a, b|
		
		b[1] <=> a[1];

    end
	
	
	
	
	#	pair_to_highest_zscore.keys.sort.each do |key|
	#		puts( "#{key}: #{pair_to_highest_zscore[key]}");
	#    end
	
	
	#	kv.each do |p|
	#		puts( "#{p[0]} #{p[1]} #{p[2]}" );
	#    end
	
	return kv;
end

def get_its_rank( its1, its2 )
	clique_size = nil
	max_dist = nil
	
	table = $its_its_table;
	
	use_fp = true
	
	
	if not use_fp
		$db_ii.execute( "select cliqueSize, maxDist from #{table} where TS_one = '#{its1}_reac_0.pdb.gz' and TS_two = '#{its2}_reac_0.pdb.gz'") do |row|
			throw "duplicate its its entry for #{its1} #{its2}" if clique_size != nil;
			clique_size = row[0].to_i;
			max_dist = row[1];

		end
	else
	#	puts( "select cnm from fp where TS_one = '#{its1}' and TS_two = '#{its2}'" );
		
		$db_ii_fp.execute( "select cnm from fp where TS_both = '#{its1}_#{its2}'") do |row|
			
			
			max_dist = row[0];
		end
	end
	
	if max_dist == nil
#		if its1 == its2
#			max_dist = 1.0
#        else
#		
		puts( "missing kegg pair #{its1} #{its2}");
#			
##			return nil;
#		end

		return [-1,-1,-1,-1];
    end
			
	
	
#	if clique_size == nil
#		#puts "clique_size == nil for '#{its1}' '#{its2}'";
#		return [-1,-1,-1];
#    end
	
	#	if clique_size < 4.0
	#		puts "clique_size too small: #{clique_size}";
	#		return -1;
	#    end
	
	rank = nil
	
	
	
	if not use_fp
		#$db_ii.execute( "select count(*) from a_n1 where TS_one = '#{its1}_reac_0.pdb.gz' and cliqueSize > #{clique_size}") do |row|
		$db_ii.execute( "select count(*) from #{table} where TS_one = '#{its1}_reac_0.pdb.gz' and maxDist >= #{max_dist}") do |row|
			rank = row[0].to_i;
		end
	else
#		stmt = "select count(*) from fp where TS_one = '#{its1}_reac_0.mol2' and cnm >= #{max_dist}";
#		puts( "sql: '#{stmt}'");
		
		$db_ii_fp.execute( "select count(*) from fp where TS_one = '#{its1}' and cnm >= #{max_dist}") do |row|
			rank = row[0].to_i;
			
			if rank == 0
				throw "rank == 0: #{its1}, #{max_dist}"
            end
		end
	end
	max_clique_size = nil
#	$db_ii.execute( "select max(cliqueSize) from #{table} where TS_one = '#{its1}_reac_0.pdb.gz'") do |row|
#		max_clique_size = row[0].to_i;
#    end
	
	max_clique_size = -1 if max_clique_size == nil;
	clique_size = -1 if clique_size == nil;
	
	return [rank, max_dist.to_f, clique_size, max_clique_size];
end

#its1 = "R03508";
##its1 = "R03508";
#its2 = "R05838";
#
#rank = get_its_rank( its1, its2 );
#puts( "rank #{its1} #{its2}: #{rank}");


def get_rank( id )
	ns = get_neighborhood( id, 0.0 );
	
	ec = pdb_to_ec(id);
	kegg = $ec_kegg[ec];
	
	#puts( "/////////////////////////////////\nid: #{id}, ec: #{ec}, kegg: #{kegg}");
	
	if ec == nil || kegg == nil
		#		throw "cannot get ec/kegg for #{id}: '#{ec}' '#{kegg}'"
		return nil;
    end
	
	best_z = -1;
	best_res = nil;
	
	
	ns.each do |n|
		other_id = n[0];
		zscore = n[1];
		other_ec = n[2];
		
		other_kegg = $ec_kegg[other_ec];
		
		if id == other_id
			next;
        end
		
		if other_kegg == nil
			
			#	puts "other_kegg == nil. pdb: '#{other_id}' ec: '#{other_ec}'";
			next;
        end
		
		
		r = get_its_rank(kegg, other_kegg);
		
		next if r == nil;
		
		(rank, max_dist, clique_size, max_clique_size) = r;
		
		
		
		#puts( "neighbor #{other_id} kegg: #{other_kegg}, zscore: #{zscore}, rank: #{rank}, #{max_dist}, #{clique_size}, #{max_clique_size}");
		
		$out_all.puts( "#{id},#{kegg},#{other_id},#{other_kegg},#{zscore},#{rank},#{max_dist},#{clique_size},#{max_clique_size}");
		
		
		if zscore > best_z
			best_z = zscore;
			best_res = [other_id, other_kegg, zscore, rank, max_dist, clique_size];
        end
	end
	
	return best_res;
end


#get_rank( "1iswA" );


#def get_dali_reps()
#	$db_dali.execute( "select distinct id1 from dali") do |row|
#	#	puts( row[0] );
#	
#		id = row[0];
#		get_rank(id);
#    end
#end


#IO.foreach($pdb90) do |l|
#	l.chomp!
#	get_rank(l)
#
#end


$out_all = File.open($out_all_name, "w");
$out_best = File.open($out_best_name, "w");
$out_all.puts("id,kegg,other_id,other_kegg,zscore,rank,max_dist,clique_size,max_clique_size" );
$out_best.puts("id,kegg,other_id,other_kegg,zscore,rank,max_dist" );

lines = IO.readlines($pdb90)
while lines.length > 0 
	
	if lines.length % 100 == 0
		puts( "#{lines.length} remaining")
    end
	begin
		r = rand(lines.length);
	
		id = lines.delete_at(r);
		id.chomp!
		
		puts( "id: #{id}");
		
		br = get_rank(id);
		
		if br != nil
			ec = pdb_to_ec(id);
			kegg = $ec_kegg[ec];
			
			(other_id, other_kegg, zscore, rank, max_dist, clique_size) = br;
#			(rank, max_dist, clique_size, max_clique_size) = br;
			$out_best.puts( "#{id},#{kegg},#{other_id},#{other_kegg},#{zscore},#{rank},#{max_dist}");
			puts( "#{id},#{kegg},#{other_id},#{other_kegg},#{zscore},#{rank},#{max_dist}");
			$out_best.flush
        else
			#$out_best.puts( "#{id},#{kegg},NULL");
		end
		$out_all.flush;
		
	rescue NameError => x
		
		puts( ">>>>>>>>>> rescue: error occured: #{x}");
	end
	
end

$out_all.close
$out_best.close
#get_dali_reps();
