# generate one pdb file form its superpostion output
require 'csv'

$dir = "/mnt/data/A/BIO-A/apostola/ch/cheminfo/admin/its_superposition"

$ec_mapping_name = '/usr/local/storage/download/mapping.txt'

cLine = -1;

$pdb_ec = {}

IO.foreach( $ec_mapping_name ) do |line|
	cLine+=1;

	next if cLine < 2;
	
	if line =~ /(\d\w{3})\s*\|\s+(\w)\s+\|.+\|.+\|.+\|\s+(\S+)/
		id = $1;
		chain = $2;
		ec = $3;
		
		#puts( "'#{id}' '#{chain}' '#{ec}'");
		
		$pdb_ec[id] = ec;
		
    end
	
end

def ec_dist( ec1, ec2 )
	if ec1 == nil || ec2 == nil 
		return 5;
    end
	
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


puts("id1\tecl3\tid2\tec1\tec2\tecd\tnalign\trmsd");
Dir["#{$dir}/*"].each do |f|
	
	
	out_csv = "#{f}/prep/out.csv";
	
	csv = CSV.open( out_csv, "r", "\t");
	
	id1 = nil;
	ecl3 = nil;
	
	
	
	if f =~ /\/(\d\w{3})_(\d+\.\d+\.\d+)/
		id1 = $1;
		ecl3 = $2;
    end
	
	f = File.open(out_csv, "r");

	first = true;
	
	csv.each do |l|  
		
		if( first )
			first = false;
			next;
        end
		
		
		
		file = l[0];
		nalign = l[9].to_i;
		rmsd = l[11].to_f;
		
		
		
		
		id2 = nil;
		
		if file =~ /output_files\/(\d\w{3})\./
			id2 = $1;
        end
		
		
		ec1 = $pdb_ec[id1];
		ec2 = $pdb_ec[id2];
		ecd = ec_dist(ec1, ec2);
		
		if nalign < 40 || rmsd > 4 || ecd != 1
			next;
        end
		
		puts( "#{id1}\t#{ecl3}\t#{id2}\t#{ec1}\t#{ec2}\t#{ecd}\t#{l[9]}\t#{l[11]}" );
    end
	
	csv.close();
end