$outcsv="/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.csv"
$outmeta="/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.meta"

first = true;

ids = {};

IO.foreach($outcsv) { |line|
	if first
		first = false;
		next;
    end
	
	
	sl = line.split( /\s+/);
	
	
	prot = sl[3];
	
#	puts( prot );

	if( prot =~ /complexes_mol2\/(.{4})/)
		id = $1;
	#	puts( "#{id}");
		
		if not ids.has_key?(id)
			ids[id] = 1;
        end
		
    end
	
}



ids.keys.sort.each do |id|
	puts( "#{id}")
end