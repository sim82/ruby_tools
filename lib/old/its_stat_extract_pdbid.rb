require 'csv'

$statname = "/home/b/berger/dipl/ext_stor/its_hd/stat/its_stat_tan_06_score_0.csv"

csv = CSV.open( $statname, "r" );

hash = {};

first = true;
csv.each do |l|
	if first 
		first = false;
		next;
    end
	
	id = l[0];
	
#	puts( id );
	
	if( id =~ /mol2_(\d\w{3})_/)
		pdbid = $1;
		
#		puts( pdbid );
		
		hash[pdbid] = pdbid;
    end
	
end

hash.keys.sort.each do |id|
	puts(id);
end