pdbid = ARGV[0]


puts Dir["/mnt/data/C/BIO-C/marialke/results/ITS_debug/R*_*_*_#{pdbid}_*ref_h.mol2/#{pdbid}_*_ref_h.mol2_R*_*_*.mol2"].join(" ")