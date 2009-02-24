#! /usr/bin/perl

foreach $file (<RAxML_info.*>) {
	$cfile = $file;
	$cfile =~ s/_info\./_classification\./g;

	#print "$file => $cfile\n";

	if( ! -e $cfile ) {
		print "$file\n";
	}
}


