$wfile = ARGV[0]
$nocalc = ARGV[1] == "--nc"

if $nocalc and ARGV[2] != nil
	$exclusive = ARGV[2]
	puts "exclusive mode: #{$exclusive}"
end

if $wfile =~ /.+\/(.+)$/
	puts "run: #{$1}"
	$run = $1
else
	throw "bad argument"
end

$wh = File.open( $wfile, "r" )

`mkdir #{$run}`
Dir.chdir($run)
$mainpath = Dir.pwd


$outh = File.open( "out.txt", "w" )

def round(f) 
	return (f * 1000.0).round / 1000.0
end

def get_average
	sum_nd = 0
	sum_bd = 0.0
	sum_bdn = 0.0
	n = 0.0;


	filewc = nil
	if $exclusive == nil
		filewc = "ext/RAxML_classification.*"
	else
		filewc = "ext/RAxML_classification.#{$exclusive}"
	end

	Dir[filewc].each do |cf|
		line = IO.readlines( cf ).first

		if line =~ /(.+)\s+(.+)\s+(.+)\s(.+)\s(.+)\s(.+)\s(.+)\s(.+)/
			n += 1.0
			taxon = $1
			branch = $2
			realbranch = $3
			support = $4
			nd = $5.to_i
			bd = $6.to_f
			bdn = $7.to_f
			treediam = $8

			sum_nd += nd
			sum_bd += bd
			sum_bdn += bdn
		else
			throw "bad line in dreedist output"
		end
	end
	return [round(sum_nd/n), round(sum_bd / n), round(sum_bdn / n)];
end


num_weights = 100
# if $wfile =~ /best/
# #	throw "b;a"
# 	num_weights = 20
# end
 
wlines = $wh.readlines.reverse[0,num_weights]
$n_so_far = 0
$sum_nd_so_far = 0.0
wlines.each do |l|
	if l =~ /(\d+)(.+)\s([\d\.]+$)/
		
		puts "#{$1}: #{$3}"
		iname = "w_#{$1}"

		`mkdir #{iname}`
		Dir.chdir( iname )


		if not $nocalc
			
			File.open( "weight", "w" ) do |cwh|
				cwh.puts( $2 )
			end

	# 		`sh ../../../../../morph_class_nobs_wgh.sh`
			`java -cp ~/workspace/java_tools/bin/ ml.RedTrees ../../../RAxML_bipartitions.DRAW_MORPH`

			Dir["RAxML_bipartitions.*_????"].each do |f|
				out = `~/workspace/raxml-hpc-float-sse3/raxmlHPC -m BINGAMMA -f v -s ../../../../morph.phy -x 1234 -t #{f} -n #{f[-4,4]} -a weight`

				File.open( "#{f}.out", "w" ) do |of|
					of.puts out
				end

			end

			jout = `java -cp ~/workspace/java_tools/bin/ ml.ClassifierLTree --auto RAxML_bipartitions.DRAW_MORPH.rn ../../../RAxML_bipartitions.DRAW_MORPH`

			if jout.length > 0 
				puts jout
			end
		end
		
		(mnd, mbd, mbdn) = get_average

		$sum_nd_so_far += mnd
		$n_so_far += 1

		puts "#{mnd} #{mbd} #{mbdn} (#{$sum_nd_so_far / $n_so_far} @ #{$n_so_far})"

		$outh.puts "#{$1} #{$3} #{mnd} #{mbd} #{mbdn}"

#		puts jout

		

	
 		Dir.chdir( $mainpath )
	end

	#throw "exit"
end


$outh.close