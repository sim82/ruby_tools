
        # Seq389  I33     I86     1       5       0.091897        0.046348        1.982763        1.975637
require( 'stringio' )

def do_rmsd( instr, outstr, seq, gap, tee ) 
    node_dist_sq = 0.0
    ref_dist_sq = 0.0
    ref_dist_norm_sq = 0.0
    
    taxon = nil
    oinpos = nil
    
    
    nreps = 0
    instr.each_line do |l|
        if l =~ /^\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/
            nreps += $1.to_i
        end
    end
    instr.rewind
    instr.each_line do |l|
        
        if l =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/
            if( tee ) 
                puts "# #{l}"
            end
            
            taxon = $1
            inpos = $2
            oinpos = $3
            bs = $4.to_i
            node_dist = $5.to_i
            ref_dist = $6.to_f
            ref_dist_norm = $7.to_f
            diam_ref = $8.to_f
            #diam_olt = $9.to_f
            
            bsf = bs / nreps.to_f
            
            node_dist_sq += bsf * (node_dist ** 2)
            ref_dist_sq += bsf * (ref_dist ** 2)
            ref_dist_norm_sq += bsf * (ref_dist_norm ** 2)
        else
            throw "bad line in input file"
        end
    end
    
    
    mean_node_dist = Math.sqrt(node_dist_sq)
    mean_ref_dist = Math.sqrt(ref_dist_sq)
    mean_ref_dist_norm = Math.sqrt(ref_dist_norm_sq)
    
    outstr.puts( "#{seq}\t#{gap}\t#{taxon}\t#{oinpos}\t#{mean_node_dist}\t#{mean_ref_dist}\t#{mean_ref_dist_norm}" );
end


if ARGV.length > 0 and ARGV[0] == "--auto"
    # auto mode
    `mkdir rmsd`
    puts "auto mode"
    
    Dir["RAxML_classification*"].each do |f|
        
        seq = 0
        gap = 0
        
        if f =~ /(\d+)\_([\d]+\w)$/
            seq = $1
            gap = $2
        end
        
        instr = File.open( f, "r" )
        outstr = File.open( "./rmsd/" + f, "w" )
        
        do_rmsd( instr, outstr, seq, gap, false )
        
        instr.close
        outstr.close
    end
    
    
else
    
    do_rmsd( StringIO.new( STDIN.readlines.join), STDOUT, 0, 0, ARGV[0] == "--tee" )
end