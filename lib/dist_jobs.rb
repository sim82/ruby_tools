$njobs = ARGV[0].to_i

$jpn = 4

$nodelist = ARGV[1,ARGV.length - 1]

if $nodelist.length * $jpn != $njobs
	throw "$nodelist.length * $jpn != $njobs #{$nodelist.length} #{$jpn} #{$njobs}"
end




1.upto( $njobs ) do |i|
	ni = (i-1) / $jpn

	puts( "ssh opt#{$nodelist[ni]}  \"cd `pwd` ; sh run_#{i}.sh > out_#{i}.txt 2> err_#{i}.txt &\"" )
	
end

