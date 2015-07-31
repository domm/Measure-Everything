package Measure::Everything::Adapter::Base;
use strict;
use warnings;

use Measure::Everything::Adapter;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

sub write {
    my $class = ref( $_[0] ) || $_[0];
    die "$class does not implement 'write'";
}

1;

