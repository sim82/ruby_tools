require 'csv';


$name = ARGV[0]

pdbid_ec3_map = {};

first = true;
CSV.foreach($name) do |l|  
	#puts( l[2]);

	
	
	if first
		first = false;
		next;
    end
	
	
	ec = l[2];
	id = l[0];
	
	
	pdbid = nil;
	ec3 = nil;
	if( id =~ /mol2\_([\w\d]{4})\_/ ) 
		pdbid = $1;
	#	puts( "pdb: #{pdbid}");
    end
	
	if( ec =~ /((\d+)\.(\d+)\.(\d+))\.(\d+)/)
		ec3 = $1;
	end
	
	throw "could not find pdbid or l3 ec ('#{id}' '#{ec}')" if pdbid == nil or ec3 == nil;
	
	pdbid_ec3_map[pdbid] = ec3;

	puts( "add: #{pdbid} #{ec3}");
end

pdbid_ec3_map.each_pair do |pdbid, ec3|
	File.open( "pdb_nl/#{pdbid}_#{ec3}", "w" ) do |h|
		h.puts(pdbid);
		IO.foreach( "ec_to_pdb3/#{ec3}") do |l|
			if( l.strip == pdbid )
				next;
            end
			h.puts(l);
        end
    end
end