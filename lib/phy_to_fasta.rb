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



ifh=$stdin
ofh=$stdout

if ARGV.length == 2
  ifh = File.open( ARGV[0], "r" )
  ofh = File.open( ARGV[1], "w" )
end

(names,seqs,cols,lines) = readphy( ifh )

names.each do |name|
	#seq = seqs[name].upcase.tr( '^ACGT', "" )
	seq = seqs[name].upcase.tr( '-?', "" )
	ofh.puts( ">#{name}\n#{seq}" )
end

if ofh != $stdout
  ofh.close
end
