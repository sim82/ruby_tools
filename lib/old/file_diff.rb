

$file1 = ARGV[0];
$file2 = ARGV[1];

if( $file2 == nil )
  throw( "missing argument");
end

hash = {};



IO.foreach($file2) { |line|
	hash[line] = true;
}


IO.foreach($file1) { |line|
	puts(line) unless hash.key?(line);
}
