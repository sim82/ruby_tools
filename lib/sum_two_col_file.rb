$out = []
$hits = []

$stdin.each_line do |l|
	cs = l.split;

	if true 
		rowidx = 8
		vidx = 4
	else
		rowidx = 0
		vidx = 1
	end

	row = cs[rowidx].to_i
	v = cs[vidx].to_f

	next if row < 0

	if row > 1300
		puts l
		throw "whuuuuuttt?"
	end

	throw "bad data" if row == nil or v == nil

	$out[row] = 0.0 if $out[row] == nil;
	$hits[row] = 0 if $hits[row] == nil;

	$out[row] += v;
	$hits[row] += 1
end


$out.each_index do |i|
	$out[i] = -1.0 if $out[i] == nil;
	avg = -1.0;
	if $hits[i] != nil
		avg = $out[i] / $hits[i]
	end

	puts "#{i}\t#{avg}\t#{$out[i]}\t#{$hits[i]}"

end