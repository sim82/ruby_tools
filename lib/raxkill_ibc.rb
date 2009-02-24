1.upto(32) do |i|
	n = ("0" * (2 - i.to_s.length)) + i.to_s
	host = "opt#{n}"
	
	cmd = "ssh #{host} \"ps ux\""
	puts cmd

	psout = `#{cmd}`

	raxpids = []

	user = "bergers"

	psout.each_line do |l|
		if l =~ /#{user}\s+(\d+).+raxmlHPC/
			puts "rax: #{$1}"
		end

		if l =~ /#{user}\s+(\d+).+sh\srun/
			puts "script: #{$1}"
		end


	end

end