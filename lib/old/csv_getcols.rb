require 'rubygems'
require 'fastercsv'


$name = ARGV[0]
fields = ARGV[1..(ARGV.length-1)]

sep = ""
FasterCSV.foreach($name, {:col_sep => "\t", :headers => true}) do |l|
	
	fd = []
	fields.each do |f|
		fd << l[f]
    end
	
	puts( fd.join( " " ));
end