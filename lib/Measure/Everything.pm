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

=head1 DESCRIPTION

=head1 TODO

=over

=item * tests

=item * docs

=item * Measure::Everything::Adapter::Memory

=item * Measure::Everything::Adapter::Test

=item * move Measure::Everything::Adapter::InfluxDB::* into seperate distribution(s)

=back

=head1 SEE ALSO

The basic concept is stolen from <Log::Any|https://metacpan.org/pod/Log::Any>. If you have troubles understanding this set of modules, please read the excellent Log::Any docs, and substitue "logging" with "writing stats".

For more information on measuring & stats, and the obvious inspiration for this module's name, read the interesting article L<Measure Anything, Measure Everything|https://codeascraft.com/2011/02/15/measure-anything-measure-everything/> by Ian Malpass from L<Etsy|http://etsy.com/>.

=head1 THANKS

Thanks to

=over

=item *

L<validad.com|http://www.validad.com/> for funding the
development of this code.

=back


