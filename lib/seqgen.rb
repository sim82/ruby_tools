first = ARGV[0].to_i
last = ARGV[1].to_i

if ARGV[2]
	pad = ARGV[2].to_i
else
	pad = ARGV[1].length
end

first.upto(last) do |i|
	puts "#{"0" * [0,pad - i.to_s.length].max}#{i}"
end

