#! /user/bin/perl -w
use strict;


my $file = shift;

my @loci = ();
open (I, "<$file") || die;
while (<I>) {
	chomp;

	if (/(^\S+)\s+(\S+)\s+(\d+)/) {
		my ($id, $chr, $coord) = ($1, $2, $3);

		my %locus = (	'id'	=> $id,
						'chr' 	=> "chr$chr",
						'coord' => $coord 
					);

		push (@loci, \%locus);
	}
}
close (I);

foreach my $key (sort {($a->{'chr'} cmp $b->{'chr'}) or ($a->{'coord'} <=> $b->{'coord'})} @loci) {
	print $key->{'chr'}."\t".($key->{'coord'}-1)."\t".$key->{'coord'}."\t".$key->{'id'}."\n";
}