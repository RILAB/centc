#!/usr/bin/perl
#Script to read in data frame with subgenome and cluster size and combine based on criteria
use strict; 
use warnings;

die "usage: AdjustCluster.pl <Dist Cutoff> <clust size>" unless @ARGV==2;

my $distcut = $ARGV[0];
my $clustsize = $ARGV[1];

open(ORIG, "<ClusterNeighbors_forscript.csv");
#open(out, ">out_$distcut.$clustsize");

my @file=<ORIG>;
my @cluster = split(/,/, $file[0]);
my @bpcentc = split(/,/, $file[5]);
my @distnext = split(/,/, $file[6]);
my @subgenome = split(/,/, $file[7]);
close ORIG;

my @clustersub = (); # array for clusters in each subgenome
my @bpsub = (); # array for bp in each subgenome
my $sumbp = 0;
my $pos = 0;

foreach my $i (1..$#distnext) {
	#if the current cluster is far away from next one or on diff subgenome
	if ( ($distnext[$i]=~m/NA/ ) || ($distnext[$i] >= $distcut) || ( $subgenome[$i] != $subgenome[$i-1]) ) { 		
		#if the current total is bigger than our cluster size of interest
		if ($sumbp >= $clustsize) { 
			$bpsub[$subgenome[$i]]+=$sumbp;
			$clustersub[$subgenome[$i]]++;
			print "$cluster[$i] added to subgenome $subgenome[$i]\n";
		}
		$sumbp = $bpcentc[$i]; #reset sumbp so you can move to next cluster
	}		
	#if distance is less than our cutoff, its tandem, and total up
	else { 
		$sumbp += $bpcentc[$i];
	}
}

for my $j (0..2){
	print "$j\t$bpsub[$j]\t$clustersub[$j]\n";
}
