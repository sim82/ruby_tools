$fuck = ARGV[0] == "--fuck"
$fuckfuck = ARGV[0] == "--fuckfuck"

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
    
    i = 0;
    
    fi.each_line do |l|
        l.chomp!
        #puts "l: #{l.length}" 
        
        if l =~ /^(\S+)\s+(\S+[\s\S]*)/
            name = $1
            data = $2
            
            data.gsub!( /\s/, "" )
            if $fuckfuck
                data = data.gsub( /\./, "-" ).upcase
                
            end
            if names.length < lines
                names << name;
                max_name = [max_name, name.length].max
            end
            
            if seqs.has_key?(name)
                seqs[name] += data
            else
                seqs[name] = data
            end
            
        elsif l =~ /^\s*(\S+[\s\S]*)/
            data = $1
            
            data.gsub!( /\s/, "" )
            if $fuckfuck
                data = data.gsub( /\./, "-" ).upcase
                
            end
            name = names[i];
            
            if not seqs.has_key?(name)
                puts "line: #{l}"
                throw "i = #{i} out of range (#{name})"
            end
            
            seqs[name] += data
            i+=1;
        elsif l =~ /^\s*$/
            i = 0;
        end
    end
    
    real_cols = nil
    
    seqs.each_value do |s|
        if $fuck
            s = s.gsub( /[\(\{].+?[\)\}]/, "x" )
        end
        
        
        real_cols = s.length if real_cols == nil
        
        if s.length != real_cols
            names.each do |n|
                puts "name: #{n}"
            end
            throw "inconsistent seq lengts #{s.length} #{real_cols}" 
        end
    end
    
    fo.puts( "#{lines} #{real_cols}")
    
    names.each do |name|
        fo.puts( "#{pad_right(max_name + 1, name)}#{seqs[name]}" )
    end
end


phy_deleaf(STDIN, STDOUT)