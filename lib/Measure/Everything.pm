package Measure::Everything;
use 5.010;
use strict;
use warnings;
use Module::Runtime qw(use_module);

our $VERSION = '1.000';
# ABSTRACT: Log::Any for Stats

our $global_stats;

sub import {
    my $class  = shift;
    my $target = shift;
    my $caller = caller();

    $target ||= '$stats';
    $target=~s/^\$//;

    if (!$global_stats) {
        $global_stats = use_module('Measure::Everything::Adapter::Null')->new;
    }

    {
        no strict 'refs';
        my $varname = "$caller\::".$target;
        *$varname = \$global_stats;
    }
}



1;


__END__


=head1 SYNOPSIS

In a module where you want to count some stats:

  package Foo;
  use Measure::Everything qw($stats);

  $stats->write('jigawats', 1.21, { source=>'Plutonium', location=>'Hill Valley' });


In your application:

  use Foo;
  use Measure::Everything::Adapter;
  Measure::Everything::Adapter->set('InfluxDB::File');


