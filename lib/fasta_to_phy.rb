def readfa( fh )
    
    rows = 0
    names = []
    
    
    seqs = {}
    
    lens = []
    
    curname = nil
    curseq = nil
    
    minlen = 1000000
    maxlen = -1
    
	maxcols = 0;
	
    fh.each_line do |l|
        name = nil
        data = nil
        #puts(l)
        if l =~ />\s*(\S+)/
            #         puts(l)
            if( curseq != nil )
                seqs[curname] = curseq;
                names << curname;
                
                lens << curseq.length
            end
            rows += 1
            curname = $1;
            curseq = ""
            maxcols = [maxcols, curseq.length].max
        elsif curname != nil
            l.gsub!( /\s/, "" )
            curseq += l
        end
    end
    maxcols = [maxcols, curseq.length].max
    seqs[curname] = curseq;
    names << curname;
    lens << curseq.length
    
    return [names, seqs, lens, rows, maxcols];
end


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

hfa = File.open( ARGV[0], "r" )
hph = File.open( ARGV[1], "w" )

(fa_names, fa_seqs, fa_lens,fa_rows,fa_cols) = readfa( hfa )
#(ph_names, ph_seqs, ph_cols, ph_lines) = readphy( $stdin )


max_name = (fa_names).map{ |n| n.length }.max

#puts( max_name );

def pad_right( c, n, s )
    if( s.length < n )
        return s + (c * (n - s.length))
    else
        return s;
    end
end

# lens.each do |l|
#     #puts l
# end
hph.puts "#{fa_names.length} #{fa_cols}"

#ph_names.each do |name|
#    puts( "#{pad_right( " ", max_name + 1, name)}#{ph_seqs[name]}" )
#end

fa_names.each do |name|
    hph.puts( "#{pad_right( " ", max_name + 1, name)}#{pad_right( "-", fa_cols, fa_seqs[name] )}" )
end
