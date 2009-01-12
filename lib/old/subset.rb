
$filename = ARGV[0];
$num = 1000;


lines = File.readlines($filename);


1.upto($num) do |i|
  r = rand( lines.length );

  id = lines.delete_at(r);
  
  puts(id);
end
