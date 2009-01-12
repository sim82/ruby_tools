require 'fileutils'

$outcsv="/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.csv"
$outmeta="/mnt/data/C/BIO-C/marialke/results/ITS_debug/out.meta"

first = true;

ids = {};

$cwd = FileUtils.pwd;

lines = []

IO.foreach($outcsv) { |line|
	if first
		first = false;
		
		puts( line );
		next;
    end
	
	
	sl = line.split( /\s+/);
	
	
	prot = sl[3];
	
#	puts( prot );

	if( prot =~ /complexes_mol2\/(.{4})/)
		id = $1;
	#	puts( "#{id}");
		
#		if not ids.has_key?(id)
#			ids[id] = 1;
#        end

		sl[3] = "#{$cwd}/#{id}.mol2.gz";
		
    end


	next if not File.exist?(sl[3]);

    
	
	#puts( sl.join("\t"));
	lines << sl.join("\t");
}

lines.sort.each do |l|
	puts(l);
end

