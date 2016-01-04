#! /usr/bin/perl -w

use strict;

my ($cfg_f, $pop_f, $ped_f) = @ARGV;

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

my @ped_line = ();

open (PED, "<$ped_f") || die;
while (<PED>) {
	chomp;

	push (@ped_line, $_);
}
close (PED);

my @arr = ();

push (@arr, 1);
push (@arr, 2);

print "arr @arr\n";



my $cmd_f = "cmd_$cfg_f\.list";

open (CMD, ">$cmd_f") || die;
for (my $n = 1; $n <= 10; $n++) {
	my $new_pop_f = "plink.set$n\_$cfg_f".".pop";
	my $new_ped_f = "plink.set$n\_$cfg_f".".ped";
	my $new_vld_f = "plink.set$n\_$cfg_f".".valid";

	my @valid_set = ();
	my @valid_pop = ();
	open (NPOP, ">$new_pop_f") || die;
	open (NPED, ">$new_ped_f") || die;
	open (VALID, ">$new_vld_f") || die;
	
	my $k = 0;
	foreach my $pop (sort {$a cmp $b} keys %reclassified_pop) {
		$k++;
		print "$pop\t";
		my $idx_r = $reclassified_pop{$pop};

		for (my $i = 0; $i < @$idx_r; $i++) {
			if ($i % 10 == ($n-1)) {
				push (@valid_set, $ped_line[$idx_r->[$i]]);
				push (@valid_pop, $pop);
			} else {
				print NPOP "$pop\n";
				print VALID "$pop\n";
				print NPED $ped_line[$idx_r->[$i]]."\n";
			}
		}
		print "@$idx_r\n";
	}
	print "k = $k\n";

	for (my $i = 0; $i < @valid_set; $i++) {
		print NPOP "-\n";
		print VALID $valid_pop[$i]."\n";
		print NPED $valid_set[$i]."\n";
	}

	close (NPED);
	close (NPOP);
	close (VALID);

	print CMD "/Volumes/SD_Storage/ancestry_v2/ancestry_from_wangyi/third_party/admixture --supervised $new_ped_f $k > $new_ped_f\.out\n";
}

close (CMD);
