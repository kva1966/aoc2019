#!/usr/bin/env perl

use Data::Dumper::Concise; 
use Function::Parameters;
use List::Util qw( any );

package Computer {
    use Moo;

    has input => (
        is => 'ro'
    );

    method evaluate() {
        my $pos = 0;

        while (1) {
            $pos = $self->handle($pos);
            last if $pos == -1;
        }

        return $self->input;
    };

    method handle($pos) {
        my $code = $self->input->[$pos];

        if ($code == 1) {
            return $self->_add($pos);
        }
        elsif ($code == 2) {
            return $self->_multiply($pos);
        }
        elsif ($code == 99) {
            return -1;
        }
        else {
            die "Bad code[$code]";
        }
    }

    method _add($pos) {
        my ($a, $b) = $self->_get_operands($pos);
        return $self->_set($pos, $a + $b);
    }

    method _multiply($pos) {
        my ($a, $b) = $self->_get_operands($pos);
        return $self->_set($pos, $a * $b);
    }

    method _set($pos, $res) {
        my $outpos = $self->input->[$pos + 3];
        $self->input->[$outpos] = $res;
        return $pos + 4;
    }

    method _get_operands($pos) {
        my $getfn = fun ($p) {
            my $v = $self->input->[$p];
            return $self->input->[$v];
        };
        return ( $getfn->($pos + 1), $getfn->($pos + 2) );
    }
};

fun compute($s, $debug=0) {
    chomp $s;
    my @input = split m/,/, $s;

    say STDERR "Input: " . Dumper(\@input) if $debug;
    my $output = new Computer(input => \@input)->evaluate();

    say STDERR "Output: " . Dumper($output) if $debug;
    return $output;
}

fun _test() {
    my $fn = fun($s) { compute($s, 1); };
    $fn->('1,0,0,0,99');
    $fn->('2,3,0,3,99');
    $fn->('2,4,4,5,99,0');
    $fn->('1,1,1,4,99,5,6,0,99');
}

# _test();

open(my $fh, "./input.dat") or die "Couldn't open input file $!";
my $str = <$fh>;
my @input = split m/,/, $str;

$input[1] = 12;
$input[2] = 2;
my $output = new Computer(input => \@input)->evaluate();

print $output->[0] . "\n";
