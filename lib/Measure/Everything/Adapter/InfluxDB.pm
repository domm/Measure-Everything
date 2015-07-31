package Measure::Everything::Adapter::InfluxDB;
use 5.010;
use strict;
use warnings;
use Carp qw(croak);
use Time::HiRes qw(gettimeofday);

use base qw(Measure::Everything::Adapter::Base);
use InfluxDB::LineProtocol qw(data2line);

sub write {
    croak "Please use a subclass of ".__PACKAGE__;
}

sub prepare_line {
    my $self = shift;
    return data2line(@_);
}

1;

