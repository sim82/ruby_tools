OUT OF ORDER

$idlist = ARGV[0];
$outname_null = ARGV[1];

#$sub = ARGV[2];

if( ARGV[1] == nil ) then
	throw "usage: this <idlist> <outname null>";
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

$prottemp_p = "_h_min.mol2.gz";

#$idtemp = "_pl";




def find_null( id, temp ) 
	name = "/mnt/data/C/BIO-C/karasz/berger/scpdb2007_prot_null/#{id}#{temp}";

	if( File.exist?(name) ) then
		return name;
	else
		return nil;
	end

end

def build_for_id_list( listname, outname_null )

	f_null = File.open( outname_null, "w" );	
	

	list = File.readlines( listname );

	list.each do |id|
		id.chomp!;
		prot_null = find_null( id, $prottemp_p );
		

		if( prot_null == nil ) then
			puts( "prot file not found: #{id}\n" );
			next;
		end
		
		
		#prot = "#{$myprotdir}/#{id}#{$prottemp}";
		lig = "#{$scpdbdir}/#{id}/#{$ligfile}";
		
		f_null.puts( "#{prot_null}\t#{lig}\t#{lig}\t#{id}_null\n" );
		
	end

	f_null.close();
	
end

build_for_id_list( $idlist, $outname_null );