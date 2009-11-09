def readphy( fh )
    fl = fh.readline
    # puts fl

    lines = -1
    cols = -1
    names = []
  
    if fl =~ /(\d+)\s+(\d+)/
        #   puts "lines: #{$1}"
        #   puts "cols: #{$2}"
        lines = $1.to_i
        cols = $2.to_i
    else
        throw "bad file"
    end

    seqs = {}

    fh.each_line do |l|
        name = nil
        data = nil
        if l =~ /(\S+)\s+(\S*)/
            name = $1
            data = $2
        else
            throw "bad line"
        end

        # puts "#{name} => #{data}"


        seqs[name] = data
        names << name;
    end

    return [names, seqs, cols, lines];
end


infile = ARGV[0]
ifh = File.open( infile, "r" )
(names,seqs,cols,lines) = readphy( ifh )
ifh.close();

ofh1 = File.open( "#{infile}.a.afa", "w" );

ofh2 = File.open( "#{infile}.q.afa", "w" );


names.each do |name|
	nng = 0;
	seq = seqs[name].upcase
	0.upto( seq.length() - 1 ) do |i|
		c = seq[i,1];
		if( !( c == '-' || c == '?' || c == 'N') )
			nng+=1;
		end
	end
	
	puts( nng );
	
	if( nng == 100 || nng == 200 )
		name = "qs-#{name}";
		ofh = ofh2;
	else
	
		ofh = ofh1;
	end
	
	
	ofh.puts( "> #{name}\n#{seq}" )
end

ofh1.close
ofh2.close