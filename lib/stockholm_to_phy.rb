names = []
data = {}

len = nil
maxnlen = 0
$stdin.each_line do |l|
    if l =~ /^(\S+)\s+(\S+)$/
        n = $1
        d = $2.gsub( /\./, "-" )
        names << n
        data[n] = d
        
        maxnlen = [maxnlen, n.length].max
        
        if len != nil && len != d.length
            throw "not equal seq lengths"
        end
        
        len = d.length
    end
    
end

puts ( "#{names.length} #{len}" )

names.each do |n|
    puts( "#{n}#{" " * (maxnlen + 1 - n.length)}#{data[n]}")
end

