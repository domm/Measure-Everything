package Measure::Everything::Adapter;
use 5.010;
use strict;
use warnings;
use Module::Runtime qw(use_module);

sub set {
    my ($self, $adapter, @args) = @_;

    $Measure::Everything::global_stats = use_module('Measure::Everything::Adapter::'.$adapter)->new(@args);
}

1;

