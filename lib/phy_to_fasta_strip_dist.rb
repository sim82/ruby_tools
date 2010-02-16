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

ofh2 = nil


i = 0
i2 = 0
names.each do |name|
    nng = 0;
    seq = seqs[name].upcase
    
    
    #strip = name =~ /^.+_\d\d$/
    
    strip = (i >= names.size - 20)
    
    #puts( strip );
    
    if strip
        is = i2.to_s
        i2 += 1
        is = ("0" * (2 - [0, is.size].max)) + is;
        
        ofh2 = File.open( "#{infile}.q.afa_#{is}", "w" ); 
        ofh = ofh2;
        seq.gsub!( /[\-N]/, "" );
    else
        
        ofh = ofh1;
    end
    
    
    
    i+=1
    ofh.puts( "> #{name}\n#{seq}" )

    if ofh2 != nil
        ofh2.close
        ofh2 = nil
    end
end

ofh1.close
