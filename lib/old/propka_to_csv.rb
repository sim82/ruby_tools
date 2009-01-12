$infile = ARGV[0];

state = 1;

if( $infile =~ /(\d\w{3})\.pka/) 
	id = $1;
else
	throw "cannot extract pdbid from filename";
end

puts( "id: #{id}");


File.open( "#{id}.csv", "w" ) do |outf|
	IO.foreach( $infile ) do |line|
		if state == 1
			if line =~ /RESIDUE    pKa   pKmodel   ligand atom-type/
				state = 2;
				next;
			end
	
	
		elsif state == 2 
			if line =~ /-------------/  
				break;
			end
			res = line[3,3];
	
			if res == "C- " 
				res = "CTR"
			end
	  
			if res == "N+ "
				res = "NTR";
			end
	
			seq = line[6,4].strip;
			chain = line[10,1];
	
			if( ! (chain =~ /\w/) )
				chain='Z'
			end
			
			
			all = "#{chain}_#{res}#{seq}";
	
			pka = line[11,7].to_f;
	
			puts("#{all} #{pka}");
			outf.puts( "#{id},#{all},#{pka}" );
	
		end
	end
end