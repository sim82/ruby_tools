$reaction_file = "/home/b/berger/dipl/ext_stor/kegg/reaction"

cur_entry = "(nil)";

puts("rid,ec");

IO.foreach($reaction_file) do |l|
	if( l =~ /ENTRY\s+(R\d{5})/) 
		cur_entry = $1;
    elsif( l =~ /ENZYME\s+(\d+\.\d+\.\d+\.\d+)$/)
		puts( "#{cur_entry},#{$1}");
    elsif( l =~ /\/\/\//) 
		cur_entry = "(nil)";
	end
end