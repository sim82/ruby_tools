Dir["jobs/*.sh"].each do |f|
	
	if f =~ /jobs\/(.+)\.sh/
		name = $1;
	else
		throw "bad filename in jobs dir: #{f}"
	end
	
	clsname = "RAxML_classification.#{name}"
	if not File.exist?(clsname)
		#puts "missing: '#{clsname}'"
		puts "qsub #{f}"
	end
end
		