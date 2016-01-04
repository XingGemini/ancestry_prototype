#! /usr/bin/perl -w
use strict; 


my $sample_pop_map_f = 'HGDP_SAMPLE_MAP';

my %samples = ();

open (MAP, "<$sample_pop_map_f") || die;
while (<MAP>) {
	chomp;

	if (/^(\S+)\s+(\S+.*)\./) {
		my ($spl, $pop) = ($1, $2);

		if (exists ($samples{$pop})) {
			my $samples_r = $samples{$pop};
			push (@$samples_r, $spl);
		} else  {
			my @arr = ($spl);
			$samples{$pop} = \@arr;
		}
	}
}
close (MAP);

my %cnt = ();
foreach my $pop (sort {$a cmp $b} keys %samples) {
	my $samples_r = $samples{$pop};
	my @s = @$samples_r;
	$cnt{$pop} = $#s + 1;
}

foreach my $pop (sort {$cnt{$b} <=> $cnt{$a}} keys %samples) {
	my $samples_r = $samples{$pop};
	my @s = @$samples_r;
	print "$pop\t$cnt{$pop}\t@s\n";
}