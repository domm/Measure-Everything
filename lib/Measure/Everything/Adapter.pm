package Measure::Everything::Adapter;
use strict;
use warnings;
use Module::Runtime qw(use_module);

# ABSTRACT: Tell Measure::Everything where to send the stats

sub set {
    my ($self, $adapter, @args) = @_;

    $Measure::Everything::global_stats = use_module('Measure::Everything::Adapter::'.$adapter)->new(@args);
}

1;

