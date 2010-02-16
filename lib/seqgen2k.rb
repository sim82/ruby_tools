first = ARGV[0].to_i
last = ARGV[1].to_i
cmd = ARGV[2, ARGV.length-2].join( " " )

pad = [ARGV[1].length + 1,4].max

cmd

first.upto(last) do |i|
    id = ("0" * [0,pad - i.to_s.length].max) + i.to_s
    
	
    c = cmd.gsub( /\%id\%/, id )
    puts c
end

