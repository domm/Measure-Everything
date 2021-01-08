package Measure::Everything::Adapter::Base;

# ABSTRACT: Base class for adapters
# VERSION

use strict;
use warnings;

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

__END__

=head1 DESCRIPTION

Base class for all Adapters. You won't need this unless you want to write an Adapter.

