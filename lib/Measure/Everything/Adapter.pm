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

__END__

=head1 SYNOPSIS

  # generic syntax
  use Measure::Everything::Adapter;
  Measure::Everything::Adapter->set('SomeAdapter', config => 'value' );

  # write InfluxDB lines to a file
  use Measure::Everything::Adapter;
  Measure::Everything::Adapter->set('InfluxDB::File', file => '/var/stats/influx.stats' );

=head1 DESCRIPTION




