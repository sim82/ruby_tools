if (ARGV[0] != "subseq" and ARGV[1] == "red") or (ARGV[1] == "red" and ARGV.length <= 8) or (ARGV[1] == "subseq" and ARGV.length <= 6)
    puts "usage: raxrun <backend> <red|subseq> <dataset> <model> <algo> <seq_start> <seq_end> [<gap_start> <gap_end>]"
    throw "missing arguments"
end

$backend = ARGV[0]
$experiment = ARGV[1]
$dataset = ARGV[2]
$model = ARGV[3]
$algo = ARGV[4]
$seq_start = ARGV[5].to_i
$seq_end = ARGV[6].to_i


if ARGV[0] == "red"
	$gap_start = ARGV[7].to_i
	$gap_end = ARGV[8].to_i

	throw "bad parameter" if ($gap_end < $gap_start or $gap_end == 0)
end

throw "bad parameter" if ($seq_start > $seq_end or $seq_end == 0)

$degalign_dir_host = "/space/subseq_alignments"

if $backend == "ibc"
	$raxml_bin = "/home/bergers/src/raxml-hpc-gz/raxmlHPC"
	$data_dir = "/home/bergers/data"
elsif $backend == "rrze"
	$raxml_bin = "/home/cluster32/tumu/tumu06/src/raxml-hpc/raxmlHPC"
	$data_dir = "/home/cluster32/tumu/tumu06/data"
else
	throw "bad backend identifier"
end

$seq_pad = 4;

$num_seq = ($seq_end - $seq_start + 1)

#
# look which inputfiles are available (on the current host) and 
# generate job-list
#
$njobs_raw = 0;
$njobs = 0;
$joblist = []

if $experiment == "subseq"
	$seq_start.upto($seq_end) do |seq|
	#left pad sequence number
		seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
		["500s", "500m", "500e"].each do |gap|
			$njobs_raw += 1

			align = "#{$degalign_dir_host}/#{$dataset}_#{seq}_#{gap}"

			xtrafilter = true;

# 			xtrafilter = ! File.exist?( "/space/lcbb_out/rsync/855_subseq_GTRGAMMA_q_ibc/RAxML_classification.855_GTRGAMMA_q_#{seq}_#{gap}" );

			if xtrafilter and (File.exist?(align) or File.exist?(align + ".gz"))
				$njobs += 1
				$joblist << [seq, gap, File.exist?(align + ".gz"), "#{$data_dir}/subseq_alignments"];
			end
		end
	end
elsif $experiment == "red"
	$seq_start.upto($seq_end) do |seq|
	#left pad sequence number
		seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
		$gap_start.step($gap_end, 10) do |gap|
			$njobs_raw += 1

			align = "#{$degalign_dir_host}/#{$dataset}_#{seq}_#{gap}"

			if File.exist?(align) or File.exist?(align + ".gz")
				$njobs += 1
				$joblist << [seq, gap, File.exist?(align + ".gz"), "#{$data_dir}/red_alignments"];
			end
		end
	end
else
	throw "bad experiment identifier"
end


puts "jobs: #{$njobs} (#{$njobs_raw})"


$jobdir = "jobs"
`mkdir #{$jobdir}`

`mkdir out`
`mkdir err`

if $backend == "rrze"
	lf = File.open( "jobs.txt", "w" )

	$joblist.each do |(seq,gap,isgz,align_dir)|
		jobname = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"


		outname = "out/#{jobname}.txt"
		errname = "err/#{jobname}.txt"
		shname = "#{$jobdir}/#{jobname}.sh"
		lf.puts shname

		File.open( shname, "w" ) do |f|

			tree = "#{$data_dir}/redtree/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
			align = "#{align_dir}/#{$dataset}_#{seq}_#{gap}"
			align += ".gz" if isgz

			f.puts "#!/bin/bash -l"
			f.puts "#PBS -l nodes=1,walltime=03:00:00 -o #{outname} -e #{errname} -N #{$model}.#{$algo}.#{seq}.#{gap}" 
			f.puts ""
			f.puts "cd $PBS_O_WORKDIR"
			f.puts ""
			f.puts "#{$raxml_bin} -x 1234 -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{jobname} -# 100"
			f.puts ""
		end
	end

	lf.close
elsif $backend == "ibc"
	$n_scripts = 128
	
	$njobs_per_script = $njobs / $n_scripts
	$mod = $njobs % $n_scripts

	#
	# output 'n_scripts' runner scripts with (hopefully) good job distribution
	#

	$ns = 1

	def open_script( n ) 
		return File.new( "#{$jobdir}/run_#{n}.sh", "w" );
	end

	$sh = open_script( $ns );

	$jobn = 0

	$joblist.each do |(seq,gap,isgz,align_dir)|
		if $ns <= $mod
			extra = 1
		else
			extra = 0
		end
		
		if $jobn >= $njobs_per_script + extra
			$sh.close
			$jobn = 0

			$ns = $ns + 1
			$sh = open_script( $ns );
		end
		$jobn = $jobn + 1

		jobname = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"

		tree = "#{$data_dir}/redtree/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
		align = "#{align_dir}/#{$dataset}_#{seq}_#{gap}"
		align += ".gz" if isgz

		$sh.puts "#{$raxml_bin} -x 1234 -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{jobname} -# 100"
# 		$sh.puts ""
	end


else
	throw "bad backend identifier"
end