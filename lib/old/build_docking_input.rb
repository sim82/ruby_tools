OUT OF ORDER

$idlist = ARGV[0];
$outname_p = ARGV[1];
$outname_pl = ARGV[2];
$outname_plm = ARGV[3];
$outname_ref = ARGV[4];
#$sub = ARGV[2];

if( ARGV[4] == nil ) then
	puts( "usage: this <idlist> <outname p> <outname pl> <outname ref>\n" );
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
$prottemp_pl = "_pl_h_min.mol2.gz";
#$idtemp = "_pl";

def find_sub( id, temp ) 
	puts( "search: #{id}\n" );
	for i in (0..10)
		name = "/home/b/berger/dipl/ext_stor/scpdb2007_sub#{i}_prolig/#{id}#{temp}";

		if( File.exist?( name )) then
			return name;
		end
	end
	#throw "protein not found in any subset: #{id}";
	return nil;
end

def find_ref( id ) 
	name = "#{$scpdbdir}/#{id}/protein.mol2";

	if( not File.exist?(name ) ) then
		throw "ref protein file not found: #{name}\n";

		return nil;
	else
		return name;
	end

end

def find_plm( id, temp ) 
	name = "/home/b/berger/dipl/ext_stor/scpdb2007_prolig_metal/#{id}#{temp}";

	if( File.exist?(name) ) then
		return name;
	else
		return nil;
	end

end

def build_for_id_list( listname, outname_p, outname_pl, outname_plm, outname_ref )
	f_p = File.open( outname_p, "w" );
	f_pl = File.open( outname_pl, "w" );
	f_plm = File.open( outname_plm, "w" );	
	f_ref = File.open( outname_ref, "w" );

	list = File.readlines( listname );

	list.each do |id|
		id.chomp!;
		prot_p = find_sub( id, $prottemp_p );
		prot_pl = find_sub( id, $prottemp_pl );
		prot_plm = find_plm( id, $prottemp_pl );
		prot_ref = find_ref( id );

		if( prot_p == nil or prot_pl == nil or prot_ref == nil) then
			puts( "prot file not found: #{id} ('#{prot_p}' '#{prot_pl}' '#{prot_ref}')\n" );
			next;
		end
		
		if( prot_plm == nil ) then
			throw "prot_plm == nil";
		end


		#prot = "#{$myprotdir}/#{id}#{$prottemp}";
		lig = "#{$scpdbdir}/#{id}/#{$ligfile}";
		f_p.puts( "#{prot_p}\t#{lig}\t#{lig}\t#{id}_p\n" );
		f_pl.puts( "#{prot_pl}\t#{lig}\t#{lig}\t#{id}_pl\n" );
		f_plm.puts( "#{prot_plm}\t#{lig}\t#{lig}\t#{id}_plm\n" );
		f_ref.puts( "#{prot_ref}\t#{lig}\t#{lig}\t#{id}_ref\n" );
	end

	f_p.close();
	f_pl.close();
	f_plm.close();
	f_ref.close();
end

build_for_id_list( $idlist, $outname_p, $outname_pl, $outname_plm, $outname_ref );