bestmap = {}

$stdin.each_line do |l|
	ls = l.split
	
	me = ls[0];
	other = ls[1];
	
	score = ls[11].to_f;
	
	if( bestmap[me] == nil ) 
		bestmap[me] = [other, score]
	else
		(op, sp) = bestmap[me];
		
		if( score > sp )
			bestmap[me] = [other, score]
		end
	end
end


bestmap.keys.sort.each do |me|
	(other, score) = bestmap[me];
	
	puts "#{me} #{other}"
end



	