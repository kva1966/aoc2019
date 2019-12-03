#!/usr/bin/env perl

use Function::Parameters;
use List::Util qw( any );

package Computer {
    use Moo;

    has input => (
        is => 'ro'
    );

    method evaluate() {
        my $data = $self->input;
        my $len = scalar @{$data};

        for my $i (0 .. ($len - 1)) {
            $self->handle_code($pos)
            print $data->[$i] . "\n";
        }

        return $data;
    };

    method handle($pos, $code) {
        die "Bad code[$code]" if ! any { $code == $_ } (1, 2, 99);
        if ($code == 1) {

        }
        elsif ($code == 2) {

        } elsif ($code == 9) {

        }
    }
};


open(my $fh, "./input.dat") or die "Couldn't open input file $!";
my $str = <$fh>;
chomp $str;

my @input = split m/,/, $str;
new Computer(input => \@input)->evaluate();
