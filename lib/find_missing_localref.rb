run = ARGV[0]
puts "run: #{run}"
clsset = {}

$print_jobs=false

Dir["RAxML_classification.*"].each do |f|
	#clslist += f + ","
	
	if f =~ /_(\d+)_(\d+)$/
		seq = $1
		gap = $2
		
		clsset["#{seq}_#{gap}"] = 1
	else
		throw "bad clsfile name: #{f}"
	end
end


jobmap = {}
if $print_jobs
	Dir["jobs/*.sh"].each do |f|
		if f =~ /_(\d+)_(\d+)\.sh$/
			seq = $1
			gap = $2
			
			jobmap["#{seq}_#{gap}"] = f
		else
			throw "bad jobfilefile name: #{f}"
		end
	end

	joblist = []
end

Dir["/space/red_alignments/#{run}_*"].each do |f|
	if f =~ /.+_(\d+)_(\d+)/
		seq = $1;
		gap = $2;
		
		key = seq + "_" + gap;
		if not clsset[key]
			puts "missing: #{key}"

			if $print_jobs
				joblist << jobmap[key];
			end
		end
		
	else
		throw "invalid alignment name: #{f}"
	end
	
end
if $print_jobs
	puts joblist.join( " " )
end