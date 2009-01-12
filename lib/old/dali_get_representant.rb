require 'csv'
require 'uri'
require 'rubygems'
require 'net/http'
require 'cgi'

$idlist = "/home/b/berger/dipl/ext_stor/its_hd/stat/pdbids_tan_gt_06.txt"

def get_best_chain(f)
	#return chain id with maximum number of contacts to its 
	# according to '/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/aatype_active_stat'
	
	chains = {}
	
	IO.foreach(f) do |l|
		if( l =~ /[active|contact]\s(\w)_/ )
			#puts( "chain: #{$1}");
		
			
			
			if( chains[$1] != nil )
				chains[$1] = chains[$1] + 1;
            else
				chains[$1] = 1;
			end 
			
        end
    end
	
	nMax = -1;
	chainMax = nil;
	
	chains.each_pair do |k,v|
		if( v > nMax )
			nMax = v;
			chainMax = k;
        end
		
    end
	
	
	#puts( "chainMax: #{chainMax}");
	return chainMax;
end


def get_its_dock_chain( id )
	stat_active_dir = "/mnt/data/C/BIO-C/karasz/berger/its_hd/stat/aatype_active_stat";
	
#	puts("id: #{id}")
	
	Dir["#{stat_active_dir}/*.mol2.txt"].each do |f|
	#	puts(f);
		if( f =~ /mol2_#{id}_/)
			#puts( "found: #{id}");
			#return f;
			
			return get_best_chain(f);
        end
    end
	
	#throw "get_its_dock_chain failed for #{id}";
	
end


def dali_query( id )
	res = Net::HTTP.get( URI.parse( "http://ekhidna.biocenter.helsinki.fi/dali/daliquery?find=#{id}"));
	#puts( "id: #{id}" );
	
	rep = nil;
	
	res.each_line do |l|
		if( l=~ /http:\/\/ekhidna\.biocenter\.helsinki\.fi\/dali\/downloads\/HTML\/(\d\w+).html/)
			rep = $1;
			
			#puts( "repres: #{rep}" )
			break;
        end
    end
	
	return rep;
end

def get_representant(id)
	
	best_chain = get_its_dock_chain(id);
	
	id_chain = "#{id}#{best_chain}";
	
	
	rep = dali_query(id_chain);
	if rep == nil
		rep = dali_query(id);
    end
	
	if rep == nil
		rep = "XXXXX";
    end
	
	puts( "#{id},#{best_chain},#{rep}");
end



puts("id,chain,repid")

IO.foreach($idlist) do |id|
	id.chomp!
	#get_its_dock_chain(id);
	
	get_representant(id);
	
end