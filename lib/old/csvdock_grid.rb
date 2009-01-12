#!/usr/bin/ruby
require 'fileutils'

$tmpdir = "/mnt/data/A/BIO-A/berger/dipl/ext_stor/csvdock_tmp"

if( ARGV[0] == nil ) then
	throw "missing arg";
end

if( ARGV[1] != nil ) then
	$token_extra = "_#{ARGV[1]}";
else 
	$token_extra = "";
end

$incsv = ARGV[0];
puts( $incsv );



$runtoken = Time.new.strftime( "%Y-%m-%d_%H-%M-%S" ) + $token_extra;

$rundir = "#{$tmpdir}/#{$runtoken}";
$indir = "#{$rundir}/in";
$outdir = "#{$rundir}/out";
$logdir = "#{$rundir}/log";




if( File.exist?( $rundir )) then
	throw "dir #{$rundir} already exists";
else 
	FileUtils.mkdir( $rundir );

	FileUtils.mkdir( $indir );
	FileUtils.mkdir( $outdir );
	FileUtils.mkdir( $logdir );
end

# $wrapname = "#{$rundir}/sun_stinks.csh";
# h = File.new( $wrapname, "w" );
# h.puts( "#!/bin/csh -f\n\n" );
# h.puts( "# this is a wrapper to get rid of the bloody cshell that is used as (unchangeable) default" );
# h.puts( "cd \"$1\"\n" );
# h.puts( "/bin/sh \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\"\n" );
# 
# h.close();

#FileUtils.chmod( 0755, $wrapname );



lines = IO.readlines( $incsv );

$header = lines.shift;

$num_cpus = 80;

$num_docks = lines.length;

$docks_per_job = $num_docks / $num_cpus + 1;

if( $docks_per_job > 10 ) then
	$docks_per_job = 10;
end

$job_serial = 0;

def job_token_to_csv_name( token ) 
	return "#{$indir}/#{token}.csv";
end

def job_token_to_log_name( token )
	return "#{$logdir}/#{token}.log";
end

def job_token_to_out_dir( token ) 
	return "#{$outdir}/#{token}";
end

def submit( list ) 

	token = $job_serial.to_s.rjust( 6, "0" );
	$job_serial = $job_serial + 1;

	fname = job_token_to_csv_name( token );

	h = File.new( fname, "w" );

#	puts( "job: >>>>>>>>>>>>>>>>>>\n" );
	
	h.puts($header);
	list.each do |l|
		h.puts( l );
	end

#	puts( "<<<<<<<<<<<<<<<<<<<<<<<\n" );
	h.close();

	return token;
end


job = nil;
job_token = [];

0.upto( $num_docks - 1 ) do |i|
	if( i % $docks_per_job == 0 ) then

		if( job != nil ) then
			job_token<< submit( job );
		end
		
		job = [];
	end

	job << lines[i];
end

if( job != nil ) then
	job_token << submit( job );
end

$cwd = FileUtils.pwd();

job_token.each do |job_token|
	
	csv = job_token_to_csv_name( job_token );
	log = job_token_to_log_name( job_token );
	out = job_token_to_out_dir( job_token );
	
	chillrun = "scripts/chillrun.sh -e docking_benchmark spring-conf/docking/glamdock.rb -o 'project.root=\"#{out}\";docking_benchmark.inputFile=\"#{csv}\";docker.noPop=20'";
#chillrun = "scripts/chillrun.sh -e docking_benchmark spring-conf/docking/glamdock.rb -o 'project.root=\"#{out}\";docking_benchmark.inputFile=\"#{csv}\";docker.noPop=50;pose_clusterer.count=100'";
  cmd = "qsub -N j#{job_token}__#{$runtoken} -o #{log} -l vf=2000M -j y -q all.q -cwd -S /bin/zsh #{chillrun}";

	puts( "cmd: \"#{cmd}\"" );
	`#{cmd}`;
end


puts( lines.length() );
puts( $runtoken );


