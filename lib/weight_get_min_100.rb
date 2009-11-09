require 'rubygems'
require 'priority_queue'

$q = PriorityQueue.new

minl = nil

mind = -10000
$stdin.each_line do |l|


	ls = l.split
	d = -ls.last.to_f

	next if d <= mind

	$q[l] = d
	if $q.length > 100
		mind = $q.delete_min_return_priority
	end

end

while not $q.empty?
	(l, p) = $q.delete_min
	#puts "#{p}: #{l}"
	puts l
end


