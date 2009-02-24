

if ARGV.length < 4
    puts "usage: raxrun <dataset> <seq_start> <seq_end> <sub_len>"
    throw "missing arguments"
end

$dataset = ARGV[0]
$seq_start = ARGV[1].to_i
$seq_end = ARGV[2].to_i
$n_scripts = ARGV[3].to_i

$raxxtra = ""


$raxml_bin = "~/local/raxml720#{$raxxtra}/raxmlHPC"
$misc_param = "-x 1234"


$model = "GTRGAMMA"
$algo = "q"


$subseqalign_dir = "~/data/subseq_alignments"
$tree_dir = "~/data/redtree"
$seq_pad = 4;

$num_seq = ($seq_end - $seq_start + 1)

$seq_per_script = $num_seq / $n_scripts
$mod = $num_seq % $n_scripts

puts( "#{$num_seq} #{$n_scripts} #{$seq_per_script} #{$mod}" );

$ns = 1

def open_script( n ) 
	return File.new( "run_#{n}.sh", "w" );
end

$sh = open_script( $ns );

$seqn = 0

#$len_levels = ["500", "250"]
$len_levels = ["500s", "500m", "500e", "500l"]


$seq_start.upto($seq_end) do |seq|
	
	if $ns <= $mod
		extra = 1
	else
		extra = 0
	end

	if $seqn >= $seq_per_script + extra
		$sh.close
		$seqn = 0

		$ns = $ns + 1
		$sh = open_script( $ns );

	end
	$seqn = $seqn + 1
    seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
    $len_levels.each do |len|
    #left pad sequence number
        

        tree = "#{$tree_dir}/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
        align = "#{$subseqalign_dir}/#{$dataset}_#{seq}_#{len}"
        name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{len}"

        num_bs = 100

        cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"

        $sh.puts cmd


    end
end


$sh.close