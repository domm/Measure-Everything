package InfluxD::FileTailer;
use strict;
use warnings;
use feature 'say';

use Moose;
use IO::Async::FileStream;
use IO::Async::Loop;
use Hijk ();
use Carp qw(croak);

has 'file' => (is=>'ro',isa=>'Str',required=>1);
has 'influx_host' => (is=>'ro',isa=>'Str',required=>1);
has 'influx_port' => (is=>'ro',isa=>'Str',required=>1);
has 'influx_db' => (is=>'ro',,isa=>'Str',required=>1);
#TODO:
# has tags = list of default tags that have to be added
# flush_size = send to influx if buffered stats are bigger than
# flush_interval = send to influx after this amount of time

my @buffer;

sub run {
    my $self = shift;
    my $loop = IO::Async::Loop->new;

    open(my $fh, "<", $self->file) || croak "Cannot open file ".$self->file.": $!";

    my $filestream = IO::Async::FileStream->new(
        read_handle => $fh,
        on_initial => sub {
            my ( $self ) = @_;
            $self->seek_to_last( "\n" );
        },

        on_read => sub {
            my ( $event, $buffref ) = @_;

            while( $$buffref =~ s/^(.*\n)// ) {
                push(@buffer, $1);
            }

            if (@buffer > 100) {
                $self->send;
            }

            return 0;
        },
    );

    $loop->add( $filestream );

    $loop->run;

}

sub send {
    my ($self) = @_;

    my $res = Hijk::request({
        method       => "POST",
        host         => $self->influx_host,
        port         => $self->influx_port,
        path         => "/write",
        query_string => "db=".$self->influx_db,
        body         => join("\n",@buffer),
    });
    say "Sent buffer to influx";
    @buffer=();
}


__PACKAGE__->meta->make_immutable;
1;
