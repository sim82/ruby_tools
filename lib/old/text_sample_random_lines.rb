
$num = ARGV[0].to_i;
$name = ARGV[1];



srand(Time.now.to_i);
def rand_uniq( n, m )
	l = [];
	
	m.times do |i|
		l << i;
    end
	
	if( n < m )
		(m-n).times do |i|
			r = rand(l.length);
			l.delete_at(r);
		end
	end
	
	return l;
end


lines = IO.readlines($name);
rand_uniq($num, lines.length).each do |i|
	puts( lines[i]);
end