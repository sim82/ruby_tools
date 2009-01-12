# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$dir = "/home/b/berger/dipl/links/scpdb2007";


Dir["#{$dir}/????"].sort.each { |dir|
	
  dir =~ /(\d\w{3})$/;


  pdbid = $1;
  #puts( pdbid );

  ligname = "#{dir}/ligand_xray.mol2";
  
  lines = IO.readlines(ligname);
  
  while( lines.length != 0 ) 
	
	line = lines.shift;
	if( line =~ /@<TRIPOS>MOLECULE/ ) then
	  break;
    end
  end
  lines.shift;
  
  line = lines.shift;
  
  if( line =~ /^\s*(\d+)/ ) then
	num = $1.to_i;
	
	puts( "#{pdbid},#{num}\n");
  end
	
}
