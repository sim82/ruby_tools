base = nil
base_ins = nil
base_ti = nil

$stdin.each_line do |l|
	if l =~ /^(\d+)\s+([\d\.]+)\s+([\d\.]+)$/
		nt = $1.to_i
		t = $2.to_f
		ti = $3.to_f

		if nt == 1
			base = t
			base_ins = t - ti
			base_ti = ti
		end


		puts "#{nt} #{t} #{t - ti} #{base / t} #{base_ins / (t - ti)} #{base_ti / ti}"
	end

end