#! /usr/bin/perl -w
use strict; 


my $sample_pop_map_f = 'HGDP_SAMPLE_MAP';

my %pop_sample = ();

open (MAP, "<$sample_pop_map_f") || die;
while (<MAP>) {
	chomp;

	if (/^(\S+)\t+(\S+.*$)/) {
		my ($spl, $pop) = ($1, $2);
		$pop =~ s/\s+/\_/g;
		$pop =~ s/\.$//g;

		$pop_sample{$spl} = $pop;
	}
}
close (MAP);


my $excluded_sample_f = "Exclude_Sample";
my %excluded_sample = ();
open (EXC, "<$excluded_sample_f") || die;
while (<EXC>) {
	chomp;

	if (/^(\S+)\t/) {
		my $sample = $1;
		$excluded_sample{$sample} = 1;
	}
}
close (EXC);

my $ped_f = shift;
my $excluded_ped_f = $ped_f;
$excluded_ped_f =~ s/ped/excluded\.ped/g;

my $pop_f = 'plink.excluded.pop';
open (PED, "<$ped_f") || die;
open (NPED, ">$excluded_ped_f") || die;
open (POP, ">$pop_f") || die;

while (<PED>) {
	chomp;

	if (/^(\S+)\s+/) {
		my $spl = $1;

		if (exists ($excluded_sample{$spl})) {
			next;
		}

		print $spl."\t".$pop_sample{$spl}."\n";
		print NPED "$_\n";
		print POP $pop_sample{$spl}."\n";
	}
}
close (POP);
close (NPED);
close (PED);