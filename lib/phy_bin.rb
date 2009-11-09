
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
    l.chomp!
    name = nil
    data = nil
    if l =~ /(\w+)\s+(\S[\w\?\(\)\{\}\-\s]*)/
        name = $1
        data = $2
    else
        throw "bad line: >>'#{l}'<<"
    end

    # puts "#{name} => #{data}"

    #    if not data.length == cols
    #      throw "wrong length #{data.length} #{cols}"
    #    end

    fuckage = 1
    if( fuckage == 1 ) 
    # a = {01} b = {12} c = {89} d = {012} e = {02} f = {04} g= 
    # {24} h = {26} i = {0123} j={23} k={123} l={013} m={13} n={023} o={03}  
    # p={35} q={34}
        data.upcase!
        data.gsub!( /A/, "(01)" );
        data.gsub!( /B/, "(12)" );
        data.gsub!( /C/, "(89)" );
        data.gsub!( /D/, "(012)" );
        data.gsub!( /E/, "(02)" );
        data.gsub!( /F/, "(04)" );
        data.gsub!( /G/, "(24)" );
        data.gsub!( /H/, "(26)" );
        data.gsub!( /I/, "(0123)" );
        data.gsub!( /J/, "(23)" );
        data.gsub!( /K/, "(123)" );
        data.gsub!( /L/, "(013)" );
        data.gsub!( /M/, "(13)" );
        #data.gsub!( /N/, "(023)" );
        data.gsub!( /O/, "(03)" );
        data.gsub!( /P/, "(35)" );
        data.gsub!( /Q/, "(34)" );
    elsif( fuckage == 2 ) 
        data.gsub!( /A/, "0" );
        data.gsub!( /C/, "1" );
    end
    data.gsub!( /\-/, "?" );
    data.gsub!( /\{/, "(");
    data.gsub!( /\}/, ")");

        #puts( ">>>>>#{data}<<<<<" )

    seqs[name] = data
    names << name;
    end

    return [names, seqs, cols, lines];
end

#
# parse multistate set (string in the form of (0134)
#
def parse_ms_set( s )
    len = s.length


    if s[0,1] != "(" or s[len-1,1] != ")"
        throw "bad multi state set"
    end

    raw = s[1,len-2]
    list = []

    0.upto( raw.length - 1 ) do |i|
        list << raw[i,1].to_i
    end
    return list
end


# convert ordinal feature in the range [0,n] to bit vector of length n
def ord_to_bin( n, i )
    if i >= n
        throw "bad arguments #{n} < #{i}"
    end

    throw "n <= 1" if n <= 1

    return ("0" * i) + "1" + ("0" * (n-i-1))
end

# convert set of ordinal feature in the range [0,n] to bit vector of length n
def ordset_to_bin( n, s )
    if s.max >= n
        throw "bad arguments #{n} < #{s}"
    end

    out = ""

    0.upto(n-1) do |i|
        if s.index(i) != nil
            out += "1"
        else
            out += "0"
        end
    end
    return out
end


def pad_right( n, s )
    if( s.length < n )
        return s + (" " * (n - s.length))
    else
        return s;
    end
end


#
# begin of script
#


(names, seqs, cols, lines) = readphy( $stdin )


$ncols = []
$outcols = nil

# count for each input column (multi-state sets count as one column each)
# the number of required output columns.
# Note: (01) needs two output columns!
seqs.each do |name, seq|
    #pointer in the input sequence
    i = 0
    
    # pointer in the output sequence (multi state sets increment this only by one)
    col = 0;

    while i < seq.length
        c = seq[i,1];

#         if c =~ /\s/
#             
#             i+=1;
#             next;
#         els
        if c =~ /\(/
            # read multi state set
            
            istart = i;

            while i < seq.length
                c2 = seq[i,1];

                break if c2 =~ /\)/;
        
                i+=1;
            end

            if i >= seq.length
                puts "seq: '#{seq}'"
                throw "could not find closing paren. pair started at #{istart}"
            end
        
            i+=1;
            
            sset = seq[istart, i - istart];

            set = parse_ms_set(sset);
    
            # the number of required output columns is the maximum state plus one,
            # because we need to encode '0's with an own column!
            ncols = set.max + 1
            
            if( $ncols[col] == nil || $ncols[col] < ncols ) 
                $ncols[col] = ncols;
            end
            
            col += 1;
            
        elsif c =~ /\d/
            ci = c.to_i

            # if we only have 0/1 we need one output column
            if ci <= 1
                ncols = 1;
            else
                ncols = ci+1;
            end
            
            if $ncols[col] == nil || $ncols[col] < ncols
                $ncols[col] = ncols;
            end
            
            i+= 1;
            col += 1;
            
        elsif c == "?"
            if $ncols[col] == nil
                $ncols[col] = 1;
            end
            col += 1;
            i += 1;
        else
           throw "bad input character: #{c}"  
        end

    end
 #   $seqs_recode[name] = recode
   
end




len = 0;

# get length of output sequences by summation of the colmax array
xxx = "#"
guide = ""
$ncols.each do |m|
    len += m
    guide += (xxx * m)
    if( xxx == "#" )
        xxx = ".";
    else
        xxx = "#"
    end
end


# find longest taxon name for output alignment
pad_width = 0
names.each do |name|
    pad_width = [name.length, pad_width].max;
end

pad_width += 2;
puts( (" " * pad_width) + guide )


#puts "len: #{len}"
puts "#{seqs.keys.length} #{len}"


seqs.each do |name, seq|
    outseq = ""

    i = 0
    col = 0;
    while i < seq.length
        c = seq[i,1]
#         if c =~ /\s/
#             i += 1;
#             next;
#         els
        if c =~ /\(/
          
            # read multi state set
            
            oldlen = outseq.length
            istart = i;

            while i < seq.length
                c2 = seq[i,1];
                break if c2 =~ /\)/;
                i+=1;
            end

            if i >= seq.length
                puts "seq: '#{seq}'"
                throw "could not find closing paren. pair started at #{istart}"
            end
        
            i+=1;
            
            sset = seq[istart, i - istart];
            set = parse_ms_set(sset);
            
            outseq += ordset_to_bin($ncols[col], set);
            
            if (outseq.length - oldlen) != $ncols[col]
                throw "bad insert at #{outseq}"
            end
            col += 1;

        else
            
            oldlen = outseq.length
            if c =~ /\d/
                d = c.to_i
    #                throw "colmax == 0" if colmax[i] == 0
            
                if $ncols[col] == 1
                    outseq += "#{d}";
                else
                    outseq += ord_to_bin($ncols[col], d);
                end

            else
                outseq += c * $ncols[col];
            end
            
            if (outseq.length - oldlen) != $ncols[col]
                throw "bad insert at #{outseq}"
            end
            col += 1;
            i += 1;
    #            sanity check of last output against colmax array
          
        end
    end

    puts "#{pad_right( pad_width, name)}#{outseq}"
    if outseq.length != len
        throw "bad output sequence #{outseq.length} != #{len}"
    end
end

