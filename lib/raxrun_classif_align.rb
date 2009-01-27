

if ARGV.length < 5
    puts "usage: raxrun <dataset> <model> <seq_start> <seq_end> <len>"
    throw "missing arguments"
end

$dataset = ARGV[0]
$model = ARGV[1]
$seq_start = ARGV[2].to_i
$seq_end = ARGV[3].to_i
$subseq_len = ARGV[4].to_i

$raxml_bin = "~/src/raxml720/raxmlHPC"
$misc_param = "-x 1234"

$subseq_dir = "~/data/subseq_alignments"
$tree_dir = "~/data/redtree"
$seq_pad = 4

$algo = "q"

def strtime
    return Time.now.strftime( "%Y_%m_%d__%H_%M_%S" );
end
$prot_name = strtime + "_#{Process.pid}.txt"
$protverbose_name = strtime + "_#{Process.pid}.v.txt"

$prot = File.new( $prot_name, "w" );

$prot.puts "ARGV: '#{ARGV.join(" ")}'"

$protverbose = File.new( $protverbose_name, "w" );
$seq_start.upto($seq_end) do |seq|
    seq = "#{"0" * [0,$seq_pad - seq.to_s.length].max}#{seq}"

    tree = "#{$tree_dir}/RAxML_bipartitions.#{$dataset}.BEST.WITH_#{seq}"
    align = "#{$subseq_dir}/#{$dataset}_#{seq}_#{$subseq_len}"
    num_bs = 100
    name = "#{$dataset}_#{$model}_#{$algo}_#{seq}_#{$subseq_len}"

    cmd = "#{$raxml_bin} #{$misc_param} -f #{$algo} -m #{$model} -t #{tree} -s #{align} -n #{name} -\# #{num_bs}"
    
    $prot.puts "=========\n#{Time.now.asctime}\ncwd: #{`pwd`.strip}\ncmd: #{cmd}"
    $protverbose.puts "=========\n#{Time.now.asctime}\ncwd: #{`pwd`.strip}\nhost: #{`hostname -f`.strip}\ncmd: #{cmd}\n>>>>>>>>"

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
    
end

$prot.close
$protverbose.close