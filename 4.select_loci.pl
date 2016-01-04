#! /usr/bin/perl -w
use strict;
use IO::Uncompress::Gunzip qw($GunzipError);

my $list_f = shift;
my $sample_f = shift;


my %loci = ();
my $idx = 0;
open (LIST, "<$list_f") || die;
while (<LIST>) {
	chomp;

	if (/^\S+\s+(\S+)/) {
		my $id = $1;
		$loci{$id} = $idx;
		$idx++;
	}
}
close (LIST);

print "finish reading $list_f\n";

my @sample = ();
my @sample_gt = ();
my %genotype = ();
my $z = IO::Uncompress::Gunzip->new( $sample_f )
    or die "IO::Uncompress::Gunzip failed: $GunzipError\n";

my $cnt = 0;
while (<$z>) {
	chomp;
	$cnt++;

	if ($cnt%1000 == 0) { print $cnt."\n"; }

	if (/^\s+(.*)/) {
		@sample = split(/\s+/, $1);

		for (my $i = 0; $i <=$#sample; $i++) {
			my $id = $sample[$i];
			$sample[$i] = "$id\t$id\t0\t0\t0\t-9";
		}
	}

	if (/^(\S+)\s+(.*)/) {
		my ($locus, $gt_str) = ($1, $2);

		if (exists ($loci{$locus})) {

			my @gt = split (/\s+/, $gt_str);

			if ($#gt != $#sample) {
				print "WARN: $locus";
			}

			for (my $i = 0; $i <=$#gt; $i++) {
				if ($gt[$i] eq '--') {
					$sample_gt[$i][$loci{$locus}] = "\t0\t0";
				} else {
					my @base = split (//, $gt[$i]);

					$sample_gt[$i][$loci{$locus}] .= "\t$base[0]\t$base[1]";
				}
			}
		}

	}
}

my $out_f = "4.out.plink.selectedloci.ped";

open (OUT, ">$out_f") || die;
for (my $i = 0; $i <=$#sample; $i++) {
	for (my $j = 0; $j < $idx; $j++) {
		$sample[$i] .= $sample_gt[$i][$j];
	}

	$sample[$i] .= "\n";
	print OUT $sample[$i];
}
close (OUT);
