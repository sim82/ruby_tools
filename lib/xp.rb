
mot = nil
tab = []

nb = 0

STDIN.each do |l|
#	puts l

	if l =~ /Time for mod opt on reference tree ([\d\.]+)/
		mot = $1.to_f
	elsif l =~ /Time after branch (\d+)\s([\d\.]+)/
		tab << [nb, $1.to_i, $2.to_f]
		nb+=1
	end

end


#puts "mot: #{mot}"

(nf, bf, tf) = tab.first
(nl, bl, tl) = tab.last

#puts "#{nf} #{nl}" 

pl = File.open( "plot.tmp", "w" )

tab.each do |(n,b,t)|
#	puts "branch #{b} after #{t}"
	puts "#{n} #{t}"
	pl.puts "#{n} #{t}"
end

pl.close

gp = IO.popen( "/usr/bin/gnuplot", "w+" )
gp.puts "plot \"plot.tmp\""
gp.puts "pause 1000"
#gp.close