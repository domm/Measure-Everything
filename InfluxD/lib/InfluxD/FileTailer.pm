package InfluxD::FileTailer;
use strict;
use warnings;
use feature 'say';

use Moose;
use IO::Async::FileStream;
use IO::Async::Loop;
use Hijk ();
use Carp qw(croak);

has 'file'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'influx_host' => ( is => 'ro', isa => 'Str', required => 1 );
has 'influx_port' =>
    ( is => 'ro', isa => 'Int', default => 8086, required => 1 );
has 'influx_db' => ( is => 'ro', isa => 'Str', required => 1 );

has 'flush_size' =>
    ( is => 'ro', isa => 'Int', required => 1, default => 100 );
has 'flush_interval' =>
    ( is => 'ro', isa => 'Int', required => 1, default => 5 );

#TODO:
# has tags = list of default tags that have to be added

my @buffer;

sub run {
    my $self = shift;
    my $loop = IO::Async::Loop->new;

    open( my $fh, "<", $self->file )
        || croak "Cannot open file " . $self->file . ": $!";

    my $filestream = IO::Async::FileStream->new(
        read_handle => $fh,
        on_initial  => sub {
            my ($self) = @_;
            $self->seek_to_last("\n");
        },

        on_read => sub {
            my ( $event, $buffref ) = @_;

            while ( $$buffref =~ s/^(.*\n)// ) {
                #$self->send_direct($1);
                push( @buffer, $1 );
            }

            if ( @buffer > $self->flush_size ) {
                $self->send;
            }

            return 0;
        },
    );

    $loop->add($filestream);

    my $timer = IO::Async::Timer::Periodic->new(    # could be Countdown
        interval => $self->flush_interval,

        on_tick => sub {
            say "Send periodic";
            $self->send;
        },
    );
    $timer->start;
    $loop->add($timer);

    $loop->run;

}

sub send {
    my ($self) = @_;
    return unless @buffer;
    say "Send buffer to influx size = " . scalar @buffer;
    my $res = Hijk::request(
        {   method       => "POST",
            host         => $self->influx_host,
            port         => $self->influx_port,
            path         => "/write",
            query_string => "db=" . $self->influx_db,
            body         => join( "\n", @buffer ),
        }
    );
    say "Sent!";
    say $res->{status};
    @buffer = ();
}

sub send_direct {
    my ( $self, $line ) = @_;
    my $res = Hijk::request(
        {   method       => "POST",
            host         => $self->influx_host,
            port         => $self->influx_port,
            path         => "/write",
            query_string => "db=" . $self->influx_db,
            body         => $line,
        }
    );
    say "Sent!";
    say $res->{status};

}

__PACKAGE__->meta->make_immutable;
1;
