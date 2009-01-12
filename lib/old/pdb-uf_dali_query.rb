require 'rubygems'
require 'fastercsv'
require 'csv'
require 'builder'

require 'sqlite3'

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
#############################################
# ec -> kegg rid
#############################################
$ec_kegg = {}
$kegg_ec = {}

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
			
			$kegg_ec[rid] = ecl;
			
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



$pdb90_hash = {}


IO.foreach($pdb90) do |l|
	l.chomp!
	
	$pdb90_hash[l] = 1;
end


def get_neighborhood(id, zthresh)
	pair_to_highest_zscore = {};
	pair_to_highest_dali_id = {};
	
	$db_dali.execute( "select seq, id1, id2, zscore from dali where (id1 = '#{id}') and zscore > #{zthresh} union select seq, id1, id2, zscore from dali where (id2 = '#{id}') and zscore > #{zthresh}") do |row|
		# this query is slow
		#$db.execute( "select id1, id2, zscore from dali where (id1 = '#{id}' or id2 = '#{id}') and zscore > 15") do |row|
		#		id1 = row["id1"];
		
		id1 = row[1];
		id2 = row[2];
		
		id1p = id1[0..3];
		id2p = id2[0..3];

		#	puts( "dali: #{id1} #{id2}");
		if( id1p != id2p && $pdb90_hash[id1] != nil && $pdb90_hash[id2] != nil)
			
			seq = row[0];

			otherid = (id == id1) ? id2 : id1;

			dir = (id == id2) ? 0 : 1;

			#uid = get_pair_uid(id1, id2);

			zscore = row[3].to_f;

			old_zscore = pair_to_highest_zscore[otherid];
			if old_zscore == nil or old_zscore < zscore
				pair_to_highest_zscore[otherid] = zscore;
				pair_to_highest_dali_id[otherid] = "#{seq}_#{dir}";
			end
		end
		#puts( "#{id1} #{id2} #{zscore}" );
		
		
    end
	
	kv = pair_to_highest_zscore.keys.map do |key| 
		[key,pair_to_highest_zscore[key],pdb_to_ec(key), pair_to_highest_dali_id[key]];
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



########################################################
# ITS neighbors
#######################################################3

def get_its_neighborhood( its1, method )
	clique_size = nil
	max_dist = nil
	
	
	if method == "fp"
		use_fp = true
	elsif method == "n1"
		table = "a_n1"
	elsif method == "n2"
		table = "a"
	else
		throw "unknown method: #{method}"
	end
		
	
	
	nl = []
	l_rid = []
	l_sim = []
	l_rank = []
	
	rank = 0
	prev_sim = nil
	rank_count = 0;
	l_rank_count = {}
	
	limit = 1000;
	
	if not use_fp
		$db_ii.execute( "select TS_two, maxDist from #{table} where TS_one = '#{its1}_reac_0.pdb.gz' order by maxDist desc limit #{limit} ") do |row|
			#	nl << "#{row[1]}\t#{row[0][0..5]}";
			l_rid << row[0][0..5]
			
			sim = row[1].to_f
			
			if prev_sim != nil
				if sim < prev_sim
					
					l_rank_count[rank] = rank_count;
					
					#	rank_count = 0;
					rank+=1;
                end
			end
			prev_sim = sim
			rank_count+=1
			
			
			l_rank << rank
			l_sim << sim
		end
	else
		#	puts( "select cnm from fp where TS_one = '#{its1}' and TS_two = '#{its2}'" );
		
		$db_ii_fp.execute( "select TS_two, cnm from fp where TS_one = '#{its1}' order by cnm desc limit #{limit}") do |row|
			#	nl << "#{row[1]}\t#{row[0]}";
			l_rid << row[0]
			
			sim = row[1].to_f
			
			
				
            if prev_sim != nil
				if sim < prev_sim
					
					l_rank_count[rank] = rank_count;
					
					#	rank_count = 0;
					rank+=1;
                end
			end
			prev_sim = sim
			rank_count+=1
			
			
			l_rank << rank
			l_sim << sim
		end
	end
	l_rank_count[rank] = rank_count;
	
	
	0.upto(l_rid.length - 1) do |i|
		#	nl << "#{l_rank_count[l_rank[i]]}\t'#{l_rank[i]}'\t#{l_sim[i]}\t#{l_rid[i]}";
		nl << [l_rank_count[l_rank[i]], l_sim[i], l_rid[i]]
    end
	
	return nl
end




$pdbuf_name = "/home/b/berger/dipl/ext_stor/pdb-uf/pdb_uf.txt"
$its_neigh_dir = "/home/b/berger/dipl/ext_stor/pdb-uf/its_neighborhood"

IO.foreach($pdbuf_name) do |id|
	id.chomp!
	#	puts("id: #{id}")
	
	zthrsh = 4
	ns = get_neighborhood(id, zthrsh);
	ec = pdb_to_ec(id);
	
	ec = "x.x.x.x" if ec == nil
	
	rid = $ec_kegg[ec];
	
	rid = 'RXXXXX' if rid == nil
	
	ns.each do |n|
		
		other_id = n[0];
		zscore = n[1];
		other_ec = n[2];
		
		other_ec = "x.x.x.x" if other_ec == nil
	
	
		other_rid = $ec_kegg[other_ec];
	
		other_rid = 'RXXXXX' if other_rid == nil
		
		if false 
			
			puts( "#{id}\t#{zscore}\t#{other_id}\t#{ec}\t#{other_ec}\t#{rid}\t#{other_rid}")
		else
			if other_rid != "RXXXXX"
				puts( "#{id}\t#{zscore}\t#{other_id}\t#{ec}\t#{other_ec}\t#{rid}\t#{other_rid}")
				$stdout.flush
				
				sim_methods = ["n1","n2","fp"];
				
				sim_methods.each do |met|
					nname = "#{$its_neigh_dir}/#{other_rid}_#{met}.csv";

					#if not File.exist?(nname);
					n = get_its_neighborhood(other_rid, met);
					File.open(nname, "w") do |h|  

						n.each do |l|
							rid = l[2];
							ecl = $kegg_ec[rid]
							
							ecl = [] if ecl == nil
							
							ecls = "[#{ecl.join(",")}]"
							
							h.puts "#{l[0]}\t#{l[1]}\t#{l[2]}\t#{ecls}";
						end
					end
                    #end
					
				end
				break
            end
			
		end
	end
end