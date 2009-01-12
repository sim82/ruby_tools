
require 'rubygems'
require 'fastercsv'

$name = ARGV[0]



def ec_dist( ec1, ec2 )
	s1 = ec1.split( /\./);
	s2 = ec2.split( /\./);

	if s1.length != 4 || s2.length != 4
		return 5;
    end

	0.upto(3) do |i|
		if s1[i] != s2[i]
			return 4 - i;
        end
    end

	return 0;
end


FasterCSV.foreach($name, {:col_sep => "|", :headers => false}) do |l|
	ec1 = l[0];
	ec2 = l[1];
	
	dist = ec_dist(ec1, ec2);
	
	puts( "#{ec1}|#{ec2}|#{dist}");
	
end