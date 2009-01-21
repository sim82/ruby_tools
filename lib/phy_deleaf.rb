def pad_right( n, s )
    if( s.length < n )
        return s + (" " * (n - s.length))
    else
        return s;
    end
end

def phy_deleaf( fi, fo )
    fl = fi.readline

    if fl =~ /(\d+)\s+(\d+)/
        #   puts "lines: #{$1}"
        #   puts "cols: #{$2}"
        lines = $1.to_i
        cols = $2.to_i
    else
        throw "bad file"
    end

    seqs = {}

    names = []

    max_name = 0;

    fi.each_line do |l|
        if l =~ /(\w+)\s+(\S*)/
            name = $1
            data = $2

            if names.length < lines
                names << name;
                max_name = [max_name, name.length].max
            end

            if seqs.has_key?(name)
                seqs[name] += data
            else
                seqs[name] = data
            end
        
        end
    end

    fo.puts( "#{lines} #{cols}")

    names.each do |name|
        fo.puts( "#{pad_right(max_name + 1, name)}#{seqs[name]}" )
    end
end


phy_deleaf(STDIN, STDOUT)