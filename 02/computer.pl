#!/usr/bin/env perl

use Data::Dumper::Concise; 
use Function::Parameters;
use List::Util qw( any );

package Computer {
    use Moo;

    has mem => (
        is => 'ro'
    );

    has _ip => (
        is => 'rw',
        default => 0
    );

    has _halted => (
        is => 'rw',
        default => 0
    );

    method evaluate() {
        while (1) {
            $self->handle();
            last if $self->_halted;
        }

        return $self->mem->[0];
    };

    method handle() {
        my $pos = $self->_ip;

        my $code = $self->mem->[$pos];

        if ($code == 1) {
            return $self->_add($pos);
        }
        elsif ($code == 2) {
            return $self->_multiply($pos);
        }
        elsif ($code == 99) {
            $self->_halt();
        }
        else {
            die "Bad code[$code]";
        }
    }

    method init_state($noun, $verb) {
        $self->mem->[1] = $noun;
        $self->mem->[2] = $verb;

        return $self;
    }

    method _add($pos) {
        my ($a, $b) = $self->_get_operands($pos);
        $self->_set($pos, $a + $b);
    }

    method _multiply($pos) {
        my ($a, $b) = $self->_get_operands($pos);
        $self->_set($pos, $a * $b);
    }

    method _set($pos, $res) {
        my $outpos = $self->mem->[$pos + 3];
        $self->mem->[$outpos] = $res;
        $self->_ip($self->_ip + 4);
    }

    method _get_operands($pos) {
        my $getfn = fun ($p) {
            my $v = $self->mem->[$p];
            return $self->mem->[$v];
        };
        return ( $getfn->($pos + 1), $getfn->($pos + 2) );
    }

    method _halt() {
        $self->_ip($self->_ip + 1);
        $self->_halted(1);
    }
};

fun compute($s, $debug=0) {
    chomp $s;
    my @input = split m/,/, $s;

    say STDERR "Input: " . Dumper(\@input) if $debug;
    my $output = new Computer(mem => \@input)->evaluate();

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

fun _part2($mem) {
    my @res;

    my @nouns = (0 .. 100);
    my @verbs = (0 .. 100);

    outerloop: for my $noun (@nouns) {
        for my $verb (@verbs) {
            my @memory = @{$mem};
            my $output = new Computer(mem => \@memory)->init_state($noun, $verb)->evaluate();
            if ($output == 19690720) {
                @res = ($noun, $verb);
                print "$noun,$verb => $output\n";
                last outerloop;
            }
        }
    }

    die "No result found!" if (scalar @res) == 0;
    use Data::Dumper::Concise; say STDERR Dumper(\@res);
    my ($noun, $verb) = @res;
    print("Result($noun|$verb): " . (100 * $noun + $verb) . "\n");
}

fun _part1($mem) {
    my @inputcopy = @{$mem};
    my $computer = new Computer(mem => \@inputcopy)->init_state(12, 2);
    my $output = $computer->evaluate();

    print $output . "\n";
}

# _test();

open(my $fh, "./input.dat") or die "Couldn't open input file $!";
my $str = <$fh>;
my @input = split m/,/, $str;

_part1(\@input);
_part2(\@input)
