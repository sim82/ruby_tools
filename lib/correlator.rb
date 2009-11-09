$infile = ARGV[0]

$sumx = nil
$sumy = 0.0

$sumxsqr = nil
$sumysqr = 0.0
$n = 0;

$sumxy = nil

IO.foreach( $infile ) do |l|
	le = l.split

	if $sumx == nil 
		$sumx = [0] * (le.length - 2)
		$sumxsqr = [0] * (le.length - 2)
		$sumxy = [0] * (le.length - 2)
	end 

	y = le.last.to_f
	
	0.upto(le.length - 3) do |i|
		x = le[1 + i].to_f / 100.0

		$sumx[i] += x
		$sumxsqr[i] += x * x
		$sumxy[i] += x * y
	end

	$n += 1
	$sumy += y
	$sumysqr += y * y


end

$sumxy.each_with_index do |i, xy|
	left = $n * xy - $sumx[i] * $sumy
	right = ((n * $sumxsqr[i] - $sumx[i]**2) * ($n * $sumysqr[i] - $sumy**2) ) ** 0.5

	puts left / right
end