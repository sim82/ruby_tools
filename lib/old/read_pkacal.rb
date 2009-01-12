

def cleancell( str )
	#remove quotes, strange characters (0xa0) and whitespaces
  
  return str.gsub( /\"/, "" ).tr( "\xa0", " " ).strip;
end

def parse_entry( la, n1, n2, chain, aa, out )
  s1 = cleancell( la[n1] );
  s2 = cleancell( la[n2] );
  #puts( "pair: '#{s1}', '#{s2}'")
  
  
  
  if( s1 == '' )
	if( s2 != '' )
	  throw "inconsistent empty pair";
    end
	
	return;
  end
  
  if( not s1 =~ /\d+/ )
	return;
  end
  
  out << ["#{chain}_#{aa}#{s1}", s2.to_f];
end

def out_csv( id, out ) 
  out.each do |v|
	puts( "#{id},#{v[0]},#{v[1]}");
  end
end


$infile = ARGV[0];

id_changed = false;
ignore = false;
out = [];
pdbid = nil;
chain = nil;

IO.foreach( $infile ) do |l|
  la = l.split(/,/);
  
  #puts( la.length );
  
  
  first = cleancell( la[0] );
  second = cleancell( la[1] );
  #puts( "first: #{la[0]} #{first} #{la.length}");
  
  #puts( "second: '#{second}'");
  
  
 
  
  if( first =~ /\d\w{3}/) 
	
		
	
	#puts( "pdbid: #{first}");
	id_changed = true;
	old_pdbid = pdbid;
	pdbid = first;
	ignore = false;
	
	#puts( out );
	
	
  end
  
  if( id_changed )
	out_csv(old_pdbid, out);
	id_changed = false;
	out = [];
	next;
  end
  
  if( ignore ) 
	next;
  end
  
  if( second =~ /model:\s*([\w\d]+)/)
	
	
	model = $1;
	if( model != "default" and model != "1" )
	  ignore = true;
	  
    else
	  chain = "A";
	  #puts( "mchain: #{chain}");
	end
	next;
	#puts( "model: #{$1}");
  elsif( second =~ /^(\w)$/ )
	#puts( "chain: #{$1}");
	chain = $1;
	next;
  end

  third = cleancell( la[2] );
  if( third =~ /residue/ ) 
	next;
  end
  #puts( la );
  #puts( l );
  #puts( chain );
  parse_entry( la, 2, 3, chain, "ASP", out );
  parse_entry( la, 4, 5, chain, "GLU", out );
  parse_entry( la, 6, 7, chain, "HIS", out );
  parse_entry( la, 8, 9, chain, "CYS", out );
  parse_entry( la, 10, 11, chain, "TYR", out );
  parse_entry( la, 12, 13, chain, "LYS", out );
  parse_entry( la, 14, 15, chain, "ARG", out );
end


out_csv( pdbid, out );