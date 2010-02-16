$stdin.each_line do |l|
	l.split.each do |t|
		if t.length > 0
			puts t
		end
	end
end
