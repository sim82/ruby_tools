

if ARGV.length < 6
    puts "usage: raxrun <dataset> <model> <seq_start> <seq_end> <gap_start> <gap_end>"
    throw "missing arguments"
end

$dataset = ARGV[0]
$model = ARGV[1]
$seq_start = ARGV[2].to_i
$seq_end = ARGV[3].to_i
$gap_start = ARGV[4].to_i
$gap_end = ARGV[5].to_i
$n_scripts = ARGV[6].to_i

$raxxtra = ""
#~/local/raxml720/raxmlHPC-PTHREADS -T 8 -f v -m GTRGAMMA -t ~/data/redtree/RAxML_bipartitions.714.BEST.WITH_0000 -s ~/data/red_alignments/714_0000_20 -n 714_GTRGAMMA_v_0000_20 -N 100 -x 1234

# if ARGV[6] == "-u"
# 	$raxxtra = "_ubuntu"
# end

$raxml_bin = "~/local/raxml-hpc#{$raxxtra}/raxmlHPC"
$misc_param = "-x 1234"

$algo = "v"


$degalign_dir = "~/data/red_alignments"
$tree_dir = "~/data/redtree"
$seq_pad = 4;

$num_seq = ($seq_end - $seq_start + 1)




$num_jobs_per_seq = 0

# approximate ugly discrete math with finite-distance simulation ;-P
$gap_start.step($gap_end, 10) do |gap|
	$num_jobs_per_seq += 1
end

$njobs = $num_seq * $num_jobs_per_seq

$njobs_per_script = $njobs / $n_scripts
$mod = $njobs % $n_scripts

puts( "#{$nseq} #{$n_scripts} #{$njobs_per_script} #{$mod}" );

$ns = 1

def open_script( n ) 
	return File.new( "run_#{n}.sh", "w" );
end

$sh = open_script( $ns );

$jobn = 0

$seq_start.upto($seq_end) do |seq|
	

    seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
    $gap_start.step($gap_end, 10) do |gap|
    #left pad sequence number
        
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
        name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"

        num_bs = 100

        cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"

        $sh.puts cmd


    end
end


$sh.close