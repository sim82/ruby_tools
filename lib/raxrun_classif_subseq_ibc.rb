if ARGV.length < 5
    puts "usage: raxrun <dataset> <model> <algo> <seq_start> <seq_end>"
    throw "missing arguments"
end

$dataset = ARGV[0]
$model = ARGV[1]
$algo = ARGV[2]
$seq_start = ARGV[3].to_i
$seq_end = ARGV[4].to_i

throw "bad parameter" if ($seq_start > $seq_end or $seq_end == 0)

$degalign_dir_host = "/space/subseq_alignments"

$raxml_bin = "/home/bergers/src/raxml-hpc-gz/raxmlHPC"
$data_dir = "/home/bergers/data"

$seq_pad = 4;

$num_seq = ($seq_end - $seq_start + 1)

#
# look which inputfiles are available (on the current host) and 
# generate job-list
#

$njobs_raw = 0;
$njobs = 0;
$joblist = []
$seq_start.upto($seq_end) do |seq|
#left pad sequence number
    seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
    ["500s", "500m", "500e"].each do |gap|
		$njobs_raw += 1

        align = "#{$degalign_dir_host}/#{$dataset}_#{seq}_#{gap}"

		if File.exist?(align) or File.exist?(align + ".gz")
			$njobs += 1
			$joblist << [seq, gap, File.exist?(align + ".gz")];
		end
    end
end




puts "jobs: #{$njobs} (#{$njobs_raw})"


$jobdir = "jobs"
`mkdir #{$jobdir}`

`mkdir out`
`mkdir err`

lf = File.open( "jobs.txt", "w" )

$joblist.each do |(seq,gap,isgz)|
	jobname = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"


	outname = "out/#{jobname}.txt"
	errname = "err/#{jobname}.txt"
	shname = "#{$jobdir}/#{jobname}.sh"
	lf.puts shname

	File.open( shname, "w" ) do |f|

		tree = "#{$data_dir}/redtree/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
		align = "#{$data_dir}/subseq_alignments/#{$dataset}_#{seq}_#{gap}"
		align += ".gz" if isgz

		f.puts "#!/bin/bash -l"
		f.puts ""
		f.puts "#{$raxml_bin} -x 1234 -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{jobname} -# 100"
		f.puts ""
	end
end

lf.close