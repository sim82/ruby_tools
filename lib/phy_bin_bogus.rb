

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


# convert ordinal feature in the range [0,n] to bit vector of length n+1
def ord_to_bin( n, i )
if i > n
    throw "bad arguments #{n} < #{i}"
end

throw "n <= 1" if n <= 1

return ("0" * i) + "1" + ("0" * (n-i))

#     if i == 0
#         return "0" * n;
#     else
#         return ("0" * (i - 1)) + "1" + ("0" * (n - i))
#     end


end

# convert set of ordinal feature in the range [0,n] to bit vector of length n
def ordset_to_bin( n, s )
    if s.max > n + 1
    throw "bad arguments #{n} < #{s}"
    end

    out = ""

    0.upto(n) do |i|
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

# $to_digit_map = {}
# $to_digit_count = 0
# 
# def map_to_digit(c)
#   dig = $to_digit_map[c]
#   
#   if dig != nil
#     return dig
#   else
#     $to_digit_count += 1
# 	
# 	if $to_digit_count >= 10
# 		throw "to_digit_count >= 10"
# 	end
# 
# 	
# 	dig = "#{$to_digit_count}"
# 	puts "new mapping: #{c} => #{dig}"
# 
#     $to_digit_map[c] = dig
# 	return dig
#   end
# 
# end


#
# begin of script
#


(names, seqs, cols, lines) = readphy( $stdin )

colmax = nil;

$seqs_recode = {}



$ms_set_map = {}

seqs.each do |name, seq|
# puts "recode: '#{name}' => '#{seq}'"
i = 0
recode = "";
while i < seq.length
    c = seq[i,1];

    if c =~ /\s/
        i+=1;
        next;
    elsif c =~ /\(/
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

    #      puts "found multi state set: #{sset}"
        set = parse_ms_set(sset);
#            /set.each do |j|
#       puts j
#     end/

        $ms_set_map["#{name}__#{recode.length}"] = set;
        recode += set.max.to_s

    else
    if not c =~ /\d/ 
        if c == "A"
            c = "0"
        elsif c == "C"
            c = "1"
        else
            c = "?"
        end


    end

        recode += c;
        i+= 1;
    end

    end
    $seqs_recode[name] = recode
end



$seqs_recode.each do |name, seq|
#    puts "'#{name}' => '#{seq}'"
    colmax = [0] * seq.length if colmax == nil

    0.upto(seq.length-1) do |i|
    c = seq[i,1];
    next if not c =~ /\d/

    colmax[i] = [colmax[i], c.to_i].max;
    end
end

colmax_str = ""
colmax.each do |d|
    colmax_str += d.to_s;
end
#puts colmax_str

#throw "end"

len = 0;

# returns the number of output columns required to
# encode multistate column with colmax
def num_cols( colmax ) 
if colmax <= 1
    return 1;
else
    return colmax + 1;
end
end

# get length of output sequences by summation of the colmax array
colmax.each do |m|
    len += num_cols(m)
end


# find longest taxon name for output alignment
pad_width = 0
names.each do |name|
    pad_width = [name.length, pad_width].max;
end

pad_width += 2;



#puts "len: #{len}"
puts "#{seqs.keys.length} #{len}"


names.each do |name|
    seq = $seqs_recode[name]
    outseq = ""

    throw "bad seq length #{seq.length} #{cols}" if seq.length != cols

    
    0.upto(seq.length - 1) do |i|
    ms_set = $ms_set_map["#{name}__#{i}"]

    if ms_set != nil
        oldlen = outseq.length
        outseq += ordset_to_bin(colmax[i], ms_set);

#           sanity check of last output against colmax array
        if (outseq.length - oldlen) != [colmax[i],1].max + 1
        throw "bad insert at #{outseq}"
        end
    else
        oldlen = outseq.length
        c = seq[i,1]
        if c =~ /\d/
        d = c.to_i
#                throw "colmax == 0" if colmax[i] == 0
        
        if colmax[i] <= 1
#                   very hysterical double check...
            throw "bad entry in colmax" if colmax[i] < d;

            outseq += "#{d}";
        else
            outseq += ord_to_bin(colmax[i], d);
        end

        else
        outseq += c * num_cols(colmax[i]);
        end

#            sanity check of last output against colmax array
        if (outseq.length - oldlen) != num_cols(colmax[i])
        throw "bad insert at #{outseq}"
        end
    end
    end

    puts "#{pad_right( pad_width, name)}#{outseq}"
    if outseq.length != len
    throw "bad output sequence #{outseq.length} != #{len}"
    end
end

