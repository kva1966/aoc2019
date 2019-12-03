#!/usr/bin/env perl

use POSIX qw( floor );
use List::Util qw( sum );

open(my $fh, "./input.dat") or die "Couldn't open input file $!";
my @masses = <$fh>;
my @fuels = map { floor($_ / 3) - 2 } @masses;
my $total = sum(@fuels);

print "$total\n";
