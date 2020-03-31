package Measure::Everything::Adapter::Stdout;
use strict;
use warnings;

use Data::Dumper qw(Dumper);

use base qw(Measure::Everything::Adapter::Base);

# ABSTRACT: Debug Adapter

sub write {
    my $self = shift;
    my @stats = @_;

    local $Data::Dumper::Varname = 'Measure_Everything_';
    print Dumper( \@stats );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Measure::Everything::Adapter::Stdout - Debug Adapter to print stats to stdout

=head1 VERSION

version 1.002

=head1 SYNOPSIS

    Measure::Everything::Adapter->set( 'Stdout' );

=head1 DESCRIPTION

Will simply Dumper-out stats to stdout for debugging or quick check.

=head1 METHODS

Just C<write()>.

=head1 AUTHOR

Jozef Kute <jozef@kutej.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Thomas Klausner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
