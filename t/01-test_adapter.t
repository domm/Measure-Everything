#!/usr/bin/perl
use warnings;
use strict;

{   package Foo;
    use Measure::Everything qw( $stats );

    sub frobnicate {
        $stats->write(Foo => @_);
    }
}

use Test::More tests => 3;

use Measure::Everything::Adapter;
my $m = Measure::Everything::Adapter->set('Test');

is_deeply $m->get_stats, [], 'initialized';

Foo::frobnicate(42);
Foo::frobnicate(13);
is_deeply $m->get_stats, [['Foo', 42], ['Foo', 13]], 'store';

$m->reset;
is_deeply $m->get_stats, [], 'reset';
