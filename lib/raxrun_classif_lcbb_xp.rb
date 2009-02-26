

if ARGV.length <= 7
    puts "usage: raxrun <dataset> <model> <algo> <seq_start> <seq_end> <gap_start> <gap_end> [<raxml_bin>]"
    throw "missing arguments"
end

$dataset = ARGV[0]
$model = ARGV[1]
$algo = ARGV[2]
$seq_start = ARGV[3].to_i
$seq_end = ARGV[4].to_i
$gap_start = ARGV[5].to_i
$gap_end = ARGV[6].to_i
$n_scripts = ARGV[7].to_i
$raxml_bin = ARGV[8]

throw "bad parameter" if ($seq_start > $seq_end or $seq_end == 0 or $gap_end < $gap_start or $gap_end == 0)


$raxxtra = ""
#~/local/raxml720/raxmlHPC-PTHREADS -T 8 -f v -m GTRGAMMA -t ~/data/redtree/RAxML_bipartitions.714.BEST.WITH_0000 -s ~/data/red_alignments/714_0000_20 -n 714_GTRGAMMA_v_0000_20 -N 100 -x 1234

# if ARGV[6] == "-u"
# 	$raxxtra = "_ubuntu"
# end

#$raxml_bin = "~/local/raxml-hpc#{$raxxtra}/raxmlHPC"
$raxml_bin = "~/local/raxml-hpc#{$raxxtra}/raxmlHPC" if $raxml_bin == nil
$misc_param = "-x 1234"



$degalign_dir_host = "/space/red_alignments"

$degalign_dir = "~/data/red_alignments"
$tree_dir = "~/data/redtree"
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
    $gap_start.step($gap_end, 10) do |gap|
		$njobs_raw += 1

        align = "#{$degalign_dir_host}/#{$dataset}_#{seq}_#{gap}"

		if File.exist?(align) or File.exist?(align + ".gz")
			$njobs += 1
			$joblist << [seq, gap, File.exist?(align + ".gz")];
		end

    end
end

puts "jobs: #{$njobs} (#{$njobs_raw})"

#throw "exit"

$njobs_per_script = $njobs / $n_scripts
$mod = $njobs % $n_scripts

puts( "#{$nseq} #{$n_scripts} #{$njobs_per_script} #{$mod}" );

#
# output runner scripts with (hopefully) good job distribution
#

$ns = 1

def open_script( n ) 
	return File.new( "run_#{n}.sh", "w" );
end

$sh = open_script( $ns );

$jobn = 0

$joblist.each do |(seq,gap,isgz)|
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


	tree = "#{$tree_dir}/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
	align = "#{$degalign_dir}/#{$dataset}_#{seq}_#{gap}"
	align += ".gz" if isgz

	name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"

	num_bs = 100

	cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"

	$sh.puts cmd
end


$sh.close