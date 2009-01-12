#!/usr/bin/ruby
require 'fileutils'

if( ARGV[1] == nil ) then
	throw "missing arg";
end

$indir = ARGV[0];
$outdir = ARGV[1];

FileUtils.mkdir( $outdir );

$outoutdir = "#{$outdir}/output_files"

FileUtils.mkdir( $outoutdir );

first = true;
csvouth = File.new( "#{$outdir}/out.csv", "w" );

Dir["#{$indir}/??????"].sort.each do |d|
	puts( "mergin in #{d}\n" );

#	Dir["#{d}/output_files/*"].each do |d2|
#		FileUtils.cp_r( d2, $outoutdir );
#	end
	
	csvh = File.new( "#{d}/out.csv" );
# skip the first line in all but the first copied file, to get rid of the csv headers
	if( not first ) then
		csvh.readline();
	end
	
	csvh.each_line() do |l|
		csvouth.puts( l );
	end
	csvh.close();
	
	if( first ) then
		first = false;
		
		FileUtils.cp( "#{d}/out.meta", $outdir );
		FileUtils.cp( "#{d}/poses.meta", $outdir );
		FileUtils.cp_r( "#{d}/configuration", $outdir );
	end
	
end

csvouth.close();

h = File.new( "#{$outdir}/merged_from.txt", "w" );
h.puts( $indir );
h.close();
