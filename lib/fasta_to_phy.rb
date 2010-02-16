def readfa( fh )
    
    rows = 0
    names = []
    
    
    seqs = {}
    
    lens = []
    
    curname = nil
    curseq = nil
    
    minlen = 1000000
    maxlen = -1
    
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
            
        elsif curname != nil
            l.gsub!( /\s/, "" )
            curseq += l
        end
    end
    
    seqs[curname] = curseq;
    names << curname;
    lens << curseq.length
    
    return [names, seqs, lens, rows];
end


(names, seqs, lens,rows) = readfa( $stdin )

max_name = names.map{ |n| n.length }.max

#puts( max_name );

def pad_right( n, s )
    if( s.length < n )
        return s + (" " * (n - s.length))
    else
        return s;
    end
end

lens.each do |l|
    #puts l
end

names.each do |name|
    puts( "#{pad_right(max_name + 1, name)}#{seqs[name]}" )
end