

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

$raxxtra = ""

if ARGV[6] == "-u"
	$raxxtra = "_ubuntu"
end

$raxml_bin = "~/src/raxml720#{$raxxtra}/raxmlHPC-PTHREADS"
$misc_param = "-T 4 -x 1234"
$algo = "y"


$degalign_dir = "~/data/degen_alignments"
$tree_dir = "~/data/redtree"
$seq_pad = 4;



$seq_start.upto($seq_end) do |seq|
    $gap_end.step($gap_start, -10) do |gap|
    #left pad sequence number
        seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"

        tree = "#{$tree_dir}/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
        align = "#{$degalign_dir}/#{$dataset}_#{seq}_#{gap}"
        name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"

        num_bs = 100

        cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"

        puts cmd


    end
end


