$col = ARGV[0].to_i
$val = ARGV[1]


$stdin.each_line do |l| 
	if l.split[$col] == $val
		puts l
	end
	
end