
chain = "Z";
id = "9XXX";
lct = 0;


puts( "id\tres\tkq\tpropka\tref")

$stdin.each_line do |l|
	lct+=1;
	
	l.chomp!
	if l =~ /chain:.*(\w)/
		chain = $1;
    elsif l =~ /id:.*(\d\w{3})/
		id = $1
    else 
	
	
	
		spl = l.split;
	
	
		if l.length != 0 and spl.length != 7
			throw( "bad line (#{lct}): '#{l}'")
		end
		
		next if l.length == 0
		
		res = spl[0].upcase
		
		res = "CTR" if res == "C-TER"
		res = "NTR" if res == "N-TER"
        
		kq = spl[3]
		propka = spl[4]
		ref = spl[6]
		
#		if ref =~ /[<|>]/
#			next
#        end
		
		if ref =~ /[<|>]*((-)?\d+(\.\d+)?).*/
		
			ref = $1
        end
		
		
		puts( "#{id}\t#{chain}_#{res}\t#{kq}\t#{propka}\t#{ref}")
	end
	
end