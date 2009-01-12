$idlist = ARGV[0];
$outname = ARGV[1];

#$sub = ARGV[2];

if( ARGV[1] == nil ) then
	puts( "usage: this <idlist> <outname>\n" );
end



#if( $sub == nil ) then
#	puts( "usage: this <idlist> <outname> <sub>\n" );
#end

#puts( "sub: #{$sub}\n" );

$scpdbdir = "/mnt/data/A/BIO-A/apostola/ch/cheminfo/admin/scpdb2007"
#$myprotdir = "/home/b/berger/dipl/ext_stor/scpdb2007_#{$sub}_prolig"

$protfile = "protein.mol2"

$ligfile = "ligand_xray.mol2"
#$reffile = "ligand_xray.mol2"


def find_prot( id ) 
	name = "#{$scpdbdir}/#{id}/#{$protfile}";

	if( File.exist?(name) ) then
		return name;
	else
		return nil;
	end

end

def build_for_id_list( listname, outname )
	f_out = File.open( outname, "w" );	
	
	f_out.puts( "protein\treference\tligand\tresID");
	list = File.readlines( listname );

	list.each do |id|
		id.chomp!;
		
		prot = find_prot( id );
		

		if( prot == nil ) then
			puts( "prot file not found: #{id}\n" );
			next;
		end
		
		


		#prot = "#{$myprotdir}/#{id}#{$prottemp}";
		lig = "#{$scpdbdir}/#{id}/#{$ligfile}";
		
		f_out.puts( "#{prot}\t#{lig}\t#{lig}\t#{id}\n" );
		
	end

	
	f_out.close();
	
end

build_for_id_list( $idlist, $outname );