lines = []
i = 0;
$stdin.each_line do |l|
	i = 0
	l.split.each do |e|
		if lines[i] == nil
			lines[i] = [e];
		else
			lines[i] << e;
		end
		i+=1
	end
end


lines.each do |l|
	puts l.join(" ")
end