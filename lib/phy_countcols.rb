
fh = STDIN

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

len = -1

fh.each_line do |l|
    name = nil
    data = nil
    if l =~ /(\w+)\s+(\S*)/
        name = $1
        data = $2
    else
        throw "bad line"
    end

    # puts "#{name} => #{data}"

    #    if not data.length == cols
    #      throw "wrong length #{data.length} #{cols}"
    #    end




    while data.sub!( /\{\d+\}/, "X" ) != nil
    end
    
    while data.sub!( /\(\d+\)/, "X" ) != nil
    end

#    puts "data: '#{data}'"
    
    len = data.length if len == -1


    if len != data.length
        throw "inconsistent line length: #{len} #{data.length} '#{l}' data: #{data}"
    end


end

puts len


