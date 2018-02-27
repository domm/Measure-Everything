package Measure::Everything::Adapter;
use strict;
use warnings;
use Module::Runtime qw(use_module);

# ABSTRACT: Tell Measure::Everything where to send the stats

sub set {
    my ($self, $adapter, @args) = @_;

    my $module_name;
    if ( $adapter =~ s/^\+// ) {
        $module_name = $adapter;
    } else {
        $module_name = 'Measure::Everything::Adapter::'.$adapter;
    }

    $Measure::Everything::global_stats = use_module($module_name)->new(@args);
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




