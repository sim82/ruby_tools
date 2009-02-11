

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

def strtime
    return Time.now.strftime( "%Y_%m_%d__%H_%M_%S" );
end
$prot_name = strtime + "_#{Process.pid}.txt"
$protverbose_name = strtime + "_#{Process.pid}.v.txt"

$seq_start.upto($seq_end) do |seq|
    seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"
    $gap_end.step($gap_start, -10) do |gap|
    #left pad sequence number
        

        tree = "#{$tree_dir}/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
        align = "#{$degalign_dir}/#{$dataset}_#{seq}_#{gap}"
        name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{gap}"

	$prot.puts "=========\n#{Time.now.asctime}\ncwd: #{`pwd`.strip}\ncmd: #{cmd}"
	$protverbose.puts "=========\n#{Time.now.asctime}\ncwd: #{`pwd`.strip}\nhost: #{`hostname -f`.strip}\ncmd: #{cmd}\n>>>>>>>>"

        num_bs = 100

        cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"

		if true
			IO.popen(cmd) do |h|
				while line = h.gets
					$stdout.puts line
					$protverbose.puts line
					$protverbose.flush

				end
			end

		else
			puts cmd
		end
		$protverbose.puts "<<<<<<<<"
		$protverbose.flush
		$prot.flush

        #puts cmd


    end
end


