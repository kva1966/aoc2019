#!/usr/bin/env perl

use Data::Dumper::Concise; 
use Function::Parameters;

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
        while (!$self->_halted) {
            $self->_exec_op();
        }

        return $self->mem->[0];
    };

    method _exec_op() {
        my $code = $self->mem->[$self->_ip];

        if ($code == 1) {
            $self->_add();
        }
        elsif ($code == 2) {
            $self->_multiply();
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

    method _add() {
        my ($a, $b) = $self->_get_operands();
        $self->_set($a + $b);
    }

    method _multiply() {
        my ($a, $b) = $self->_get_operands();
        $self->_set($a * $b);
    }

    method _set($res) {
        my $outpos = $self->mem->[$self->_ip + 3];
        $self->mem->[$outpos] = $res;
        $self->_ip($self->_ip + 4);
    }

    method _get_operands() {
        my $getfn = fun ($p) {
            my $v = $self->mem->[$p];
            return $self->mem->[$v];
        };

        my $pos = $self->_ip;
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
    my $computer = new Computer(mem => \@input);
    my $output = $computer->evaluate();

    say STDERR "Output: res[$output], mem:" . Dumper($computer->mem) if $debug;
    return $output;
}

fun _test(:$debug = 0) {
    return if !$debug;
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
    my $expected_result = 19690720;

    # Brute forcing? Any better/faster way, e.g. binary search
    outerloop: for my $noun (@nouns) {
        for my $verb (@verbs) {
            my @memory = @{$mem};
            my $output = new Computer(mem => \@memory)->init_state($noun, $verb)->evaluate();
            if ($output == $expected_result) {
                @res = ($noun, $verb);
                print "$noun,$verb => $output\n";
                last outerloop;
            }
        }
    }

    die "No result found!" if (scalar @res) == 0;
    say STDERR Dumper(\@res);
    my ($noun, $verb) = @res;
    print("Result($noun|$verb): " . (100 * $noun + $verb) . "\n");
}

fun _part1($mem) {
    my @inputcopy = @{$mem};
    my $computer = new Computer(mem => \@inputcopy)->init_state(12, 2);
    my $output = $computer->evaluate();

    print $output . "\n";
}

_test(debug => 0);

open(my $fh, "./input.dat") or die "Couldn't open input file $!";
my $str = <$fh>;
my @input = split m/,/, $str;

_part1(\@input);
_part2(\@input)
