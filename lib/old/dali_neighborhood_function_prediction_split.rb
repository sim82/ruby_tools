require 'rubygems'
require 'fastercsv'

ll = nil
lastid = nil



def gen_rank( ll, key )
	rank = 0
	l_rank = []
	l_rank_count = {}
	prev_val = nil
	rank_count = 0;
	ll.each do |l|
		val = l[key].to_f
		
		if prev_val != nil
			if val < prev_val
				l_rank_count[rank] = rank_count
				
				rank += 1
			end
		end
		prev_val = val
		rank_count+=1
		
		l_rank << rank
    end
	l_rank_count[rank] = rank_count;
	
	
	l_out = []
	
	l_rank.each do |r|
		l_out << l_rank_count[r];
    end
	
	return l_out
end


$basedir = "/usr/local/storage/its_its_function_prediction"
$inname = ARGV[0]
throw "missing argument" if $inname == nil

$outdir = "#{$basedir}/#{$inname}.dir"


def process( outname, ll )
	lr = gen_rank(ll, "zscore");
	
	throw "wooooot" if ll.size != lr.size
	
	i = 0
	
	name = "#{$outdir}/#{outname}.csv"
	
	File.open( name, "wb" ) do |h|

		h.puts( "id\tkegg\tother_id\tother_kegg\tzscore\tzscore_rank\tits_sim\tits_rank")
		
		ll.each do |l|
	
			zscore_rank = lr[i]
		
			id = l["id"]
			kegg = l["kegg"]
	
			other_id = l["other_id"]
			other_kegg = l["other_kegg"]
	
			zscore = l["zscore"]
			its_rank = l["rank"]
			its_sim = l["max_dist"].to_f
		
			
			if its_sim >= 0.0
				h.puts( "#{id}\t#{kegg}\t#{other_id}\t#{other_kegg}\t#{zscore}\t#{zscore_rank}\t#{its_sim}\t#{its_rank}")
			end
			i+=1
		end
	end
end




$name = "#{$basedir}/#{$inname}.csv"

FasterCSV.foreach($name, {:col_sep => ",", :headers => true}) do |l|
	id = l["id"];
	
	
	if id != lastid
		if ll != nil
			process(lastid, ll);
        end
		
		ll = []
		lastid = id
    end
	
	its_sim = l["max_dist"].to_f;
	
	if its_sim >= 0.0
		ll << l;
	end
end