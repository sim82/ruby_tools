names = []
data = {}

len = nil
maxnlen = 0
$stdin.each_line do |l|
	if l =~ /^#/
		next
    elsif l =~ /^(\S+)\s+(\S+)$/
        n = $1
        d = $2.gsub( /\./, "-" )
        
		if data[n] == nil
			names << n
			data[n] = d
			
			maxnlen = [maxnlen, n.length].max
		else
			data[n] << d
		end
        
        
    end
    
end





first = true;

names.each do |n|
	
	
	seq = data[n]
	
	if first
		puts ( "#{names.length} #{seq.length}" )
		first = false
	end
	
	puts( "#{n}#{" " * (maxnlen + 1 - n.length)}#{seq}")
end

