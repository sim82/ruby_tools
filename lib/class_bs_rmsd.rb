
	# Seq389  I33     I86     1       5       0.091897        0.046348        1.982763        1.975637
node_dist_sq = 0.0
ref_dist_sq = 0.0
ref_dist_norm_sq = 0.0

taxon = nil
oinpos = nil

STDIN.each_line do |l|

	if l =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/
		taxon = $1
		inpos = $2
		oinpos = $3
		bs = $4.to_i
		node_dist = $5.to_i
		ref_dist = $6.to_f
		ref_dist_norm = $7.to_f
		diam_ref = $8.to_f
		diam_olt = $9.to_f

		bsf = bs / 100.0

		node_dist_sq += bsf * (node_dist ** 2)
		ref_dist_sq += bsf * (ref_dist ** 2)
		ref_dist_norm_sq += bsf * (ref_dist_norm ** 2)
	end
end


mean_node_dist = Math.sqrt(node_dist_sq)
mean_ref_dist = Math.sqrt(ref_dist_sq)
mean_ref_dist_norm = Math.sqrt(ref_dist_norm_sq)

puts( "#{taxon}\t#{oinpos}\t#{mean_node_dist}\t#{mean_ref_dist}\t#{mean_ref_dist_norm}" );