1.upto(32) do |i|
	n = ("0" * (2 - i.to_s.length)) + i.to_s
	host = "opt#{n}"
	
	cmd = "ssh #{host} \"ps ux\""
	puts cmd

	psout = `#{cmd}`

	raxpids = []
	shpids = []

	user = "bergers"

	psout.each_line do |l|
		if l =~ /#{user}\s+(\d+).+raxmlHPC/
			
			pid = $1.to_i

			puts "rax: #{pid}"
			raxpids << pid
		end

		if l =~ /#{user}\s+(\d+).+sh\srun/
			pid = $1.to_i

			puts "script: #{pid}"
			shpids << pid
		end
	end

	if shpids.length > 0 
		shkill = "kill #{shpids.join(" ")}"
		cmd = "ssh #{host} \"#{shkill}\""
		puts "running '#{cmd}'"
		puts `#{cmd}`	
	end


	if raxpids.length > 0 
		raxkill = "kill #{raxpids.join(" ")}"
		cmd = "ssh #{host} \"#{raxkill}\""
		puts "running '#{cmd}'"
		puts `#{cmd}`
	end

	

	
	

	



	

	

end