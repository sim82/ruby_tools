n1 = ARGV[0]
n2 = ARGV[1]

l1 = IO.readlines( n1 );
l2 = IO.readlines( n2 );


if l1.length != l2.length
	throw "same number of lines expected for both input files."
end

0.upto( l1.length - 1 ) do |i|
	
	puts "#{l1[i].strip} #{l2[i].strip}"
end
