require 'rexml/document'
require 'rexml/xpath'

require 'rubygems'
require 'fastercsv'
require 'csv'
require 'builder'

require 'sqlite3'

$stat_name = "/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/its_stat_tan_06_score_0.csv"

$its_its_sq3_name = '/usr/local/storage/its_its/its_its.sq3'

$dali_sq3_name = '/usr/local/storage/download/dali_idx.sq3'
$ec_mapping_name = '/usr/local/storage/download/mapping.txt'

$pdb_dali_repr_name = "/home/b/berger/dipl/ext_stor/its_hd/stat/pdb_to_dali_representant.csv"

$kegg_ec_name = "/home/b/berger/dipl/ext_stor/kegg/reaction"


$db_ii = SQLite3::Database.new( $its_its_sq3_name );

$db = SQLite3::Database.new( $dali_sq3_name );
#$db.results_as_hash = true

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


$ec_kegg = {}
$kegg_ec = {}
#FasterCSV.foreach($kegg_ec_name, {:col_sep => ",", :headers => true}) do |l|
#	$ec_kegg[l["ec"]] = l["rid"];
#end


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


$pdb_to_dalirepr = {}

FasterCSV.foreach($pdb_dali_repr_name, {:col_sep => ",", :headers => true}) do |l|
	id = l["id"];
	repid = l["repid"];
	
	$pdb_to_dalirepr[id] = repid;
	
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

def get_pair_uid( id1, id2 ) 
	if id1 > id2
		return "#{id1}_#{id2}";
    else
		return "#{id2}_#{id1}";
	end
end



def get_neighborhood(id, zthresh)
	pair_to_highest_zscore = {};
	pair_to_highest_dali_id = {};
	
	$db.execute( "select seq, id1, id2, zscore from dali where (id1 = '#{id}') and zscore > #{zthresh} union select seq, id1, id2, zscore from dali where (id2 = '#{id}') and zscore > #{zthresh}") do |row|
		# this query is slow
		#$db.execute( "select id1, id2, zscore from dali where (id1 = '#{id}' or id2 = '#{id}') and zscore > 15") do |row|
		#		id1 = row["id1"];
		
		id1 = row[1];
		id2 = row[2];
		
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
		
		#puts( "#{id1} #{id2} #{zscore}" );
		
		
    end
	
	kv = pair_to_highest_zscore.keys.map do |key| 
		[key,pair_to_highest_zscore[key],pdb_to_ec(key), pair_to_highest_dali_id[key]];
    end.sort do |a, b|
		# sort by ec number (ascending) and zscore (descending)
		
		if a[2] != b[2]
			a[2] <=> b[2]
        else
			b[1] <=> a[1];
		end
    end
	
	
	
	
	#	pair_to_highest_zscore.keys.sort.each do |key|
	#		puts( "#{key}: #{pair_to_highest_zscore[key]}");
	#    end
	
	
	#	kv.each do |p|
	#		puts( "#{p[0]} #{p[1]} #{p[2]}" );
	#    end
	
	return kv;
end

def kegg_img( rid )
	
	name = "/home/users/apostola/public_html/ts2D/#{rid}_0.png";
	
	
	return File.exist?(name) ? name : nil;
end

#get_neighborhood("1u15D", 25);

def ec_dist( ec1, ec2 )
	s1 = ec1.split( /\./);
	s2 = ec2.split( /\./);

	if s1.length != 4 || s2.length != 4
		return 5;
    end

	0.upto(3) do |i|
		if s1[i] != s2[i]
			return 4 - i;
        end
    end

	return 0;
end



def write_html() 

	xm = Builder::XmlMarkup.new(:target=>$stdout, :indent=>2)
	xm.instruct! 
	xm.html { 

		xm.body {




			FasterCSV.foreach($stat_name, {:col_sep => ",", :headers => true}) do |l|
				last_rid = "0xdeadbeef";		
				xm.hr;
				xm.hr("height"=>"5px");
				xm.hr;
				xm.div {
					dock_id = l["id"];
					#				chain = l["chain"];

					id = nil;
					kegg = nil
					if dock_id =~ /(R\d{5})_.*mol2_(\d\w{3})_/
						kegg = $1;
						id = $2
					else
						throw "cannot parse pdbid from #{dock_id}";
					end


					#repid = l["repid"];

					repid = $pdb_to_dalirepr[id];

					if repid == nil 
						throw "cannot get dali representant for #{id}";
					end


					#idc = "#{id}#{chain}";

					ec = pdb_to_ec(id);
					ecrep = pdb_to_ec(repid);

					#kegg = $ec_kegg[ec];

					xm.big {
						xm.b {
							xm.text!( "id: #{id} #{kegg} " )

							eclist = $kegg_ec[kegg];

							if eclist != nil
								xm.text!(eclist.join(" "));
							end

							xm.br;


							if( repid != "XXXXX")
								xm.text!( "dali representant: #{repid} #{ecrep}" );
							else
								xm.text!( "no dali representant" );
								next
							end
						}
					}
					next if repid == "XXXXX";
					if ec =~ /1\.1\.1\.\d+/
						xm.br;
						xm.text!( "ignore: NADH");
						next
					end

					if ec =~ /2\.5\.1\.18/
						xm.br;
						xm.text!( "ignore: glutathione");
						next
					end


					xm.br;

					img_url = kegg_img(kegg);


					if img_url != nil
						xm.img( "src"=>img_url);
					else
						xm.text!("no picture");
					end
					xm.hr;

					ns = get_neighborhood(repid, 10);

					xm.ul {
						ns.each do |n|
							other_kegg = $ec_kegg[n[2]];

							if other_kegg != last_rid


								xm.hr;

								if other_kegg != nil

									xm.big {

										xm.text!("reaction: '#{other_kegg}'");
									}
									xm.br;

									$db_ii.execute( "select maxDist, cliqueSize from a_n1 where TS_one = '#{kegg}_reac_0.pdb.gz' and TS_two = '#{other_kegg}_reac_0.pdb.gz'") do |row|
										xm.text!( "dist: #{row[0]} size: #{row[1]}");
										xm.br;
									end

									img_url = kegg_img(other_kegg);


									if img_url != nil
										xm.img( "src"=>img_url);
									else
										xm.text!("no picture");
									end
								else
									xm.big {
										xm.text!("kegg id not found for ec: #{n[2]}");
									}
								end
								last_rid = other_kegg;
							end
							xm.li {


								keggout = other_kegg != nil ? other_kegg : "no kegg RId";
								ec_other = n[2];

								ecd = ec_dist(ec, ec_other)
								xm.text!("\t#{n[0]}   #{n[1]}   #{n[2]}   #{keggout} ecd: #{ecd}" );
							}
						end
					}
				}
			end
		}
	}
end

class ReactionPair
	attr_accessor :id_repr, :ec_repr, :id1, :kegg1, :ec1, :id2, :kegg2, :ec2, :dali_id, :zscore, :ecd, :itsDist, :cliqueSize
	
	def initialize( id_repr, ec_repr, id1, kegg1, ec1, id2, kegg2, ec2, dali_id, zscore, ecd, itsDist, cliqueSize )
		@id_repr = id_repr
		@ec_repr = ec_repr
		

		@id1 = id1
		@kegg1 = kegg1
		@ec1 = ec1
		
		@id2 = id2
		@kegg2 = kegg2
		@ec2 = ec2
		
		@dali_id = dali_id
		
		@zscore = zscore
		@ecd = ecd
		
		@itsDist = itsDist
		@cliqueSize = cliqueSize;
	end
	
	def write()
		puts( "#{@id_repr}\t#{@ec_repr}\t#{@id1}\t#{@kegg1}\t#{@ec1}\t#{@id2}\t#{@kegg2}\t#{@ec2}\t#{@zscore}\t#{@ecd}\t#{@itsDist}\t#{@cliqueSize}\t#{@kegg1}+#{@kegg2}\t#{@dali_id}")
    end
	
end


def write_raw()
	puts( "id_repr\tec_repr\tid1\tkegg1\tec1\tid2\tkegg2\tec2\tzscore\tecd\titsDist\tcliqueSize\tkp\tdali_id" )
	
	FasterCSV.foreach($stat_name, {:col_sep => ",", :headers => true}) do |l|
		dock_id = l["id"];
		#				chain = l["chain"];

		id = nil;
		kegg = nil
		if dock_id =~ /(R\d{5})_.*mol2_(\d\w{3})_/
			kegg = $1;
			id = $2
		else
			throw "cannot parse pdbid from #{dock_id}";
		end


		#repid = l["repid"];

		repid = $pdb_to_dalirepr[id];
		ec = pdb_to_ec(id);
		ecrep = pdb_to_ec(repid);
		ns = get_neighborhood(repid, 10);
		
		nbk = {};
		ns.each do |n|
			zscore = n[1];
			other_id = n[0];
			other_ec = n[2];
			dali_id = n[3];
			
			other_kegg = $ec_kegg[other_ec];
			
			other_kegg = other_kegg != nil ? other_kegg : "RXXXXX";
			
			l = nbk[other_kegg];
			if l == nil
				l = [];
				nbk[other_kegg] = l;
            end
			
			ecd = ec_dist(ec, other_ec)
			
			
			itsDist = "X"
			cliqueSize = "X"
			
				
			l << ReactionPair.new( repid, ecrep, id, kegg, ec, other_id, other_kegg, other_ec, dali_id, zscore, ecd, itsDist, cliqueSize);
		end

		nbk.keys.each do |k|
			l = nbk[k];
			
			l_sort = l.sort do |a,b|
				b.zscore <=> a.zscore;
            end
			
			
#			l_sort.each do |rp|
#				rp.write
#            end
			if l_sort != nil
				itsDist = "X"
				cliqueSize = "X"
				
				rp = l_sort[0];
				
				$db_ii.execute( "select maxDist, cliqueSize from a_n1 where TS_one = '#{rp.kegg1}_reac_0.pdb.gz' and TS_two = '#{rp.kegg2}_reac_0.pdb.gz'") do |row|
					itsDist = row[0]
					cliqueSize = row[1]
				end	

				rp.itsDist = itsDist;
				rp.cliqueSize = cliqueSize;
				
				rp.write
            end
			
        end
		
    end
	
	
	
	
end

#write_raw();
write_html();
