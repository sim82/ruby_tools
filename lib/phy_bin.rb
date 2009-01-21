

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
        if l =~ /(\w+)\s+(\S[\w\?\(\)\s]*)/
            name = $1
            data = $2
        else
            throw "bad line"
        end

        # puts "#{name} => #{data}"

        #    if not data.length == cols
        #      throw "wrong length #{data.length} #{cols}"
        #    end

        data.sub!( /\{/, "(");
        data.sub!( /\}/, ")");

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
    if i > n
        throw "bad arguments #{n} < #{i}"
    end

    throw "n <= 0" if n <= 0

    if i == 0
        return "0" * n;
    else
        return ("0" * (i - 1)) + "1" + ("0" * (n - i))
    end
end

# convert set of ordinal feature in the range [0,n] to bit vector of length n
def ordset_to_bin( n, s )
    if s.max > n
        throw "bad arguments #{n} < #{s}"
    end

    out = ""
  
    1.upto(n) do |i|
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

colmax = nil;

$seqs_recode = {}



$ms_set_map = {}

seqs.each do |name, seq|
    puts "recode: '#{name}' => '#{seq}'"
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
                throw "could not find closing paren. pair started at #{istart}"
            end
      
            i+=1;

            sset = seq[istart, i - istart];

            puts "found multi state set: #{sset}"
            set = parse_ms_set(sset);
            /set.each do |j|
        puts j
      end/

            $ms_set_map["#{name}__#{recode.length}"] = set;
            recode += set.max.to_s

        else
            recode += c;
            i+= 1;
        end

    end
    $seqs_recode[name] = recode
end



$seqs_recode.each do |name, seq|
    puts "'#{name}' => '#{seq}'"
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
puts colmax_str

#throw "end"

len = 0;


# get length of output sequences by summation of the colmax array
colmax.each do |m|
    if m > 0
        len += m;
    else
        len += 1;
    end
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
            if (outseq.length - oldlen) != [colmax[i],1].max
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
                outseq += c * [colmax[i],1].max;
            end

#            sanity check of last output against colmax array
            if (outseq.length - oldlen) != [colmax[i],1].max
                throw "bad insert at #{outseq}"
            end
        end
    end

    puts "#{pad_right( pad_width, name)}#{outseq}"
    if outseq.length != len
        throw "bad output sequence #{outseq.length} != #{len}"
    end
end

