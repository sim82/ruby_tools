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




def pad_right( n, s )
	if( s.length < n )
		return s + (" " * (n - s.length))
	else
		return s;
	end
end

def write_phy( fo, names, seqs, cols, lines )
	max_name = 0;
	names.each do |n|
		max_name = [max_name, n.length].max;
	end	

	fo.puts( "#{lines} #{cols}" )
	names.each do |name|
		fo.puts( "#{pad_right(max_name + 1, name)}#{seqs[name]}" )
	end
end



(names,seqs,cols,lines) = readphy( $stdin )

#perm = Array(0..lines-1);
0.upto(lines-2) do |n|
	r = n + 1 + rand( lines - n - 1);
	
	tmp = names[r];
	names[r] = names[n];
	names[n] = tmp;
end


lines1 = lines / 2
lines2 = lines - lines1

names1 = names[0,lines1];
names2 = names[lines1,lines-1];

names1.sort!
names2.sort!

File.open( "1", "wb" ) do |f|
	write_phy( f, names1, seqs, cols, lines1 );
end


File.open( "2", "wb" ) do |f|
	write_phy( f, names2, seqs, cols, lines2 );
end
