#! /usr/bin/perl -w

use strict;

my ($cfg_f, $pop_f, $k) = @ARGV;

my %selected_pop = ();
my %pop_map = ();
open (CFG, "<$cfg_f") || die;
while (<CFG>) {
	chomp;

	if (/^(\S+)\t(\S+)/) {
		my ($pop, $new_pop) = ($1, $2);
		my @arr = ();
		$selected_pop{$pop} = \@arr;
		$pop_map{$pop} = $new_pop;
	}
}
close (CFG);

my $idx = 0;
my %reclassified_pop = ();

open (POP, "<$pop_f") || die;
while (<POP>) {
	chomp;

	if (/^(\S+)/) {
		my $pop = $1;
		if (exists ($selected_pop{$pop})) {
			if (exists ($reclassified_pop{$pop_map{$pop}})) {
				my $idx_r = $reclassified_pop{$pop_map{$pop}};
				print "$pop_map{$pop}, $pop, $idx\t";
				push (@$idx_r, $idx);
			} else {
				my @idx = ();
				push (@idx, $idx);
				$reclassified_pop{$pop_map{$pop}} = \@idx;
			}
		}
	} else {
		print "WTF $_\n";
	}
	
	$idx++
}
close (POP);
print "\n";


my $cmd_f = "cmd_$cfg_f\.list";

my %positive_predition = ();
my %total_sample = ();
my %predition = ();

my @reclassified_pop = (sort {$a cmp $b} keys %reclassified_pop);

for (my $n = 1; $n <= 10; $n++) {
	my $new_pop_f = "plink.set$n\_$cfg_f".".pop";
	my $new_vld_f = "plink.set$n\_$cfg_f".".valid";
	my $q_f = "plink.set$n\_$cfg_f".".$k\.Q";

	open (NPOP, "<$new_pop_f") || die;
	open (VALID, "<$new_vld_f") || die;
	open (Q, "<$q_f") || die;

	my $pop_idx = 0;
	while (<NPOP>) {
		chomp;

		if (/^(\S+)/) {
			my $pop = $1;
			if ($pop eq '-') {
				next;
			}
			$pop_idx++;
		}
	}

	print "pop idx $pop_idx\n";

	my @valid_pop = ();
	my $valid_idx = 0;
	while (<VALID>) {
		chomp;

		if (/^(\S+)/) {
			my $pop = $1;
			if ($valid_idx >= $pop_idx) {
				if (exists ($total_sample{$pop})) {
					$total_sample{$pop}++;
				} else {
					$total_sample{$pop} = 1;
				}
				push (@valid_pop, $pop);
			}
			$valid_idx++;
		}
	}

	#print "@valid_pop\n";

	my $q_idx = 0;
	while (<Q>) {
		chomp;

		if (/^\S+/) {
			my $line = $_;
			if ($q_idx >= $pop_idx) {
				my @arr = split (/\s+/, $line);
				my $max_idx = &getMaxIdx (\@arr);
				my $ans = shift(@valid_pop);

				print "here $reclassified_pop[$max_idx] vs $ans\n";
				if ($reclassified_pop[$max_idx] eq $ans) {
					if (exists ($positive_predition{$ans})) {
						$positive_predition{$ans} ++;
					} else {
						$positive_predition{$ans} = 1;
					}
				}
					
				if (exists ($predition{$reclassified_pop[$max_idx]})) {
					$predition{$reclassified_pop[$max_idx]} ++;
				} else {
					$predition{$reclassified_pop[$max_idx]} = 1;
				}
			}

			$q_idx ++;
		}
	}


	close (Q);
	close (NPOP);
	close (VALID);
}


for (my $i = 0; $i < @reclassified_pop; $i++) {
	my $pop = $reclassified_pop[$i];

	my $acc = $positive_predition{$pop}/$total_sample{$pop};
	my $spec = $positive_predition{$pop}/$predition{$pop};
	print "$pop\t$positive_predition{$pop}\t$total_sample{$pop}\t$predition{$pop}\t$acc\t$spec\n";
}

sub getMaxIdx () {
	my ($arr_r) = @_;

	my $max_idx = 0;
	my $max = $arr_r->[0];

	for (my $i = 1; $i < @$arr_r; $i++) {
		if ($arr_r->[$i] > $max) {
			$max_idx = $i;
			$max = $arr_r->[$i];
		}
	}

	return $max_idx;
}
