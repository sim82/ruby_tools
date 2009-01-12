

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
    if l =~ /(\w+)\s+(\S+)/
      name = $1
      data = $2
    else
      throw "bad line"
    end

   # puts "#{name} => #{data}"

    if not data.length == cols
      throw "wrong length #{data.length} #{cols}"
    end

    seqs[name] = data
    names << name;
  end

  return [names, seqs, cols, lines];
end

# convert ordinal feature in the range [0,n] to bit vector of length n
def ord_to_bin( n, i )
  if i > n
    throw "bad arguments #{n} < #{i}"
  end

  if i == 0
    return "0" * n;
  else
    return ("0" * (i - 1)) + "1" + ("0" * (n - i))
  end
end



(names, seqs, cols, lines) = readphy( $stdin )

colmax = nil;

seqs.each_value do |seq|
  colmax = [0] * seq.length if colmax == nil
  
  0.upto(seq.length-1) do |i|
    c = seq[i,1];
    next if not c =~ /\d/

    colmax[i] = [colmax[i], c.to_i].max;
  end
end


#colmax.each do |d|
#  puts d
#end

len = 0;

colmax.each do |m|
  if m > 0
    len += m;
  else
    len += 1;
  end
end

pad_width = 0

names.each do |name|
  pad_width = [name.length, pad_width].max;
end

pad_width += 2;


def pad_right( n, s )
  if( s.length < n )
    return s + (" " * (n - s.length))
  else
    return s;
  end
end

#puts "len: #{len}"
puts "#{seqs.keys.length} #{len}"
names.each do |name|
  seq = seqs[name]
  outseq = ""

  throw "bad seq length #{seq.length} #{cols}" if seq.length != cols
  0.upto(seq.length - 1) do |i|
    c = seq[i,1]
    if c =~ /\d/
      d = c.to_i
      if colmax[i] <= 1
        throw "bad entry in colmax" if colmax[i] < d;
        
        outseq += "#{d}";
      else
        outseq += ord_to_bin(colmax[i], d);
      end
      
    else
      outseq += c * colmax[i];
    end
  end
  puts "#{pad_right( pad_width, name)}#{outseq}"

end

