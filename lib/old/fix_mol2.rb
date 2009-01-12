# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'fileutils';
broken = false;

filename = ARGV[0];

IO.foreach(filename) { |line|
  if( line =~ /^@TRIPOS<SUBSTRUCTURE>/ )
	broken = true;
	break;
  end
  
  
}


if( broken ) 
  tmpname = filename + ".fix.tmp";
  
  
  if( File.exist?(tmpname)) 
	throw "cannot create tmpfile (exists). bailing out because we don't want to break anything.";
  end
  
  FileUtils.mv( filename, tmpname );
  
  out = File.new( filename, "wb" );
  
  IO.foreach(tmpname) { |line|
	if( line =~ /^@TRIPOS<SUBSTRUCTURE>/ )
	  line = "@<TRIPOS>SUBSTRUCTURE";
    end
	
	out.puts(line);
	
  }
  out.close();

  puts("fixed");
else 

  puts( "not broken");
end