def salt_term( aa, salt )
	if( aa == 'Asp' )
		return "#{salt}\t0.0\t0.0\t0.0\t0.0\t0.0";
    elsif( aa == 'Glu')
		return "0.0\t#{salt}\t0.0\t0.0\t0.0\t0.0";
	elsif( aa == 'His')
		return "0.0\t0.0\t#{salt}\t0.0\t0.0\t0.0";
	elsif( aa == 'Cys')
		return "0.0\t0.0\t0.0\t#{salt}\t0.0\t0.0";
	elsif( aa == 'Lys')
		return "0.0\t0.0\t0.0\t0.0\t#{salt}\t0.0";
	elsif( aa == 'Tyr')
		return "0.0\t0.0\t0.0\t0.0\t0.0\t#{salt}";
	else
		return "0.0\t0.0\t0.0\t0.0\t0.0\t0.0";
	end
end



$infile = ARGV[0];

first = true;
IO.foreach( $infile ) do |line|
	
	#puts( line );
	
	line.chomp!;
	
	if( first ) 
		puts( "#{line}\tsalt\tsalt_asp\tsalt_glu\tsalt_his\tsalt_cys\tsalt_lys\tsalt_tyr" );
		first = false;
		next;
    end
	
	
	if( line =~ /(\w{4})\s+(\w{3})\s+(\w?\d+)\s+([\d\.]+)\s+(\w)\s+\"(.+)\"\s+\"(.+)\"/ )
		id = $1;
		aa = $2;
		res = $3.to_i;
		pka = $4.to_f;
		x = $5;
		method = $6;
		conc = $7;
	
		#puts( "#{id} #{aa} #{conc}");
		
		salt = 0.0;
		
		if( conc =~ /([\d\.]+)\s*(m?)\s*M?\s*KCl/) 
			#puts( "KCl: #{$1} #{$2}")
			kcl = $1.to_f;
			if( $2 == "m" )
				kcl /= 1000.0;
            end
			
			#puts( "kcl: #{kcl}");
			salt += kcl;
        end
		
		if( conc =~ /([\d\.]+)\s*(m?)\s*M?\s*NaCl/) 
			#puts( "NaCl: #{$1} #{$2}")
			nacl = $1.to_f;
			if( $2 == "m" )
				nacl /= 1000.0;
            end
			
			#puts( "nacl: #{nacl}");
			salt += nacl;
        end
		
		puts( "#{line}\t#{salt}\t#{salt_term(aa, salt)}");
		
	else
		puts( "fail: #{line}")
	end
		
	
end


