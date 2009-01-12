# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$csvname = ARGV[0];


csvh = File.new( $csvname );

csvh.readline();




csvh.each_line() { |line|  
  s = line.split(/\t/);
	
  if( s.length != 27 ) then
	throw( "not 27 columns" );
  end
	  
  id = s[14];

  #puts( "id: #{id}\n");
  
  if( id =~ /(\d\w{3}).*/ ) then
	pdbid = $1;
  else 
	throw "resultID malformed: #{id}"
  end
  
  #puts( "pdbid: #{pdbid}\n" );
  
  s[14] = pdbid;
  
  
  
  puts(s.join(","));
  
}
csvh.close();

