package Measure::Everything::Adapter::Test;

# ABSTRACT: Test Adapter: for testing...
# VERSION

use strict;
use warnings;

use base qw(Measure::Everything::Adapter::Base);

sub init {
    my $self = shift;
    $self->{_stats} = [];
}

sub write {
    my $self = shift;

    push(@{$self->{_stats}}, [@_]);
}

=method get_stats

  my $stats = $stats->get_stats;

Returns all the stats collected in the raw format (i.e. as an array).

=cut

sub get_stats {
    my $self = shift;

    return $self->{_stats};
}

=method reset

  $stats->reset;

Flushes all stats collected so far, starts from a clean slate.

=cut

sub reset {
    my $self = shift;

    $self->{_stats} = [];
}

1;
__END__

=head1 SYNOPSIS

    Measure::Everything::Adapter->set( 'Test' );

=head1 DESCRIPTION

Collect stats in an in-memory array. Useful when you want to test if things are measured.

