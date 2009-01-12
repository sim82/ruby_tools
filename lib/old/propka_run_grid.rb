$indir = ARGV[0]
$inlist = ARGV[1]
$outdir = ARGV[2]

if $indir == nil || $inlist == nil || $outdir == nil
	throw "too few paramters"
end



IO.foreach($inlist) do |n|
	n.chomp!
	
	inname = "#{$indir}/#{n}"
	
	if !File.exist?( inname )
		throw "cannot find input file '#{inname}'"
    end
	
	id = 'XXX'
	
	# look for the first thing in the input name that looks like a pdb id
	if n =~ /(\D)?(\d\w{3})_/
		id = $2
    end
	
	#jcall = "/usr/lib64/jdk1.6.0_04/bin/java -cp `scripts/cp.sh`:bin"
	jparam = "org.jcowboy.poj.algo.preparation.protonation.PropkaBenchmark"
	
	
	
	if n =~ /(.+)\.mol2(.gz)?/
		inbase = $1;
    else
		throw "cannot parse basename if '#{inname}'"
	end
	
	
	
	outcsv = "#{$outdir}/#{inbase}.csv"
	outmol = "#{$outdir}/#{inbase}.mol2.gz"
	
	log = "#{outcsv}.stdout"
	
	qsub = "qsub -N j#{inbase} -o #{log} -l vf=2000M -j y -q all.q -cwd -S /bin/zsh"
	
	if File.exist?(outcsv)
		puts("skip: #{outcsv}");
		next;
    end
	
	cmd = "scripts/sge_java_runner2.sh #{jparam} #{id} #{inname} #{outcsv} #{outmol}"
	
	#puts( "#{qsub} #{cmd}" )
	`#{qsub} #{cmd}`
end

