package InfluxD::FileTailer;
use strict;
use warnings;
use feature 'say';

use Moose;
use IO::Async::File;
use IO::Async::FileStream;
use IO::Async::Loop;
use Hijk ();
use Carp qw(croak);
use Measure::Everything::InfluxDB::Utils qw(line2data data2line);
use Log::Any qw($log);
use File::Spec::Functions;

has 'dir'         => ( is => 'ro', isa => 'Str', required => 1 );
has 'influx_host' => ( is => 'ro', isa => 'Str', required => 1 );
has 'influx_port' =>
    ( is => 'ro', isa => 'Int', default => 8086, required => 1 );
has 'influx_db' => ( is => 'ro', isa => 'Str', required => 1 );

has 'flush_size' =>
    ( is => 'ro', isa => 'Int', required => 1, default => 100 );
has 'flush_interval' =>
    ( is => 'ro', isa => 'Int', required => 1, default => 5 );
has 'tags' => ( is => 'ro', isa => 'HashRef', predicate => 'has_tags' );
has '_files' => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has '_loop' => ( is => 'ro', isa => 'IO::Async::Loop', lazy_build => 1 );

sub _build__loop {
    return IO::Async::Loop->new;
}

# TODO some performance improvements:
# when starting to watch a file, check if we have a matching pid in the process table. If not, don't watch it!
# when adding new files, also check for pids..
# AND / OR:
# store the mtime of each file, and don't watch files with mtime older than $some_interval

my @buffer;

sub run {
    my $self = shift;

    unless ( -d $self->dir ) {
        croak "Not a directory: " . $self->dir;
    }

    $log->infof( "Starting InfluxD::FileTailer in directory %s", $self->dir );

    $self->watch_dir;

    my $dir = IO::Async::File->new(
        filename         => $self->dir,
        on_mtime_changed => sub {
            $self->watch_dir;
        },
    );

    $self->_loop->add($dir);

    my $timer = IO::Async::Timer::Periodic->new(    # could be Countdown
        interval => $self->flush_interval,
        on_tick  => sub {
            $self->send;
        },
    );
    $timer->start;
    $self->_loop->add($timer);

    $self->_loop->run;
}

sub watch_dir {
    my ($self) = @_;

    $log->infof( "Checking for new files to watch in %s", $self->dir );
    opendir( my $dh, $self->dir );
    while ( my $f = readdir($dh) ) {
        next unless $f =~ /\.stats$/;
        next if $self->_files->{$f};
        if ( my $watcher =
            $self->setup_file_watcher( catfile( $self->dir, $f ) ) ) {
            $self->_loop->add($watcher);
            $self->_files->{$f}++;
        }
    }
    closedir($dh);
}

sub setup_file_watcher {
    my ( $self, $file ) = @_;
    if ( open( my $fh, "<", $file ) ) {
        my $filestream = IO::Async::FileStream->new(
            read_handle => $fh,
            on_initial  => sub {
                my ($stream) = @_;
                $stream->seek_to_last("\n");    # TODO remember last position?
            },

            on_read => sub {
                my ( $stream, $buffref ) = @_;

                while ( $$buffref =~ s/^(.*\n)// ) {
                    my $line = $1;
                    if ( $self->has_tags ) {
                        $line = $self->add_tags_to_line($line);
                    }
                    push( @buffer, $line );
                }

                if ( @buffer > $self->flush_size ) {
                    $self->send;
                }

                return 0;
            },
        );
        $log->infof( "Tailing file %s", $file );
        return $filestream;
    }
    else {
        $log->errorf( "Could not open file %s: %s", $file, $! );
        return;
    }
}

sub send {
    my ($self) = @_;
    return unless @buffer;

    $log->debugf( "Sending %i lines to influx", scalar @buffer );
    my $res = Hijk::request(
        {   method       => "POST",
            host         => $self->influx_host,
            port         => $self->influx_port,
            path         => "/write",
            query_string => "db=" . $self->influx_db,
            body         => join( "\n", @buffer ),
        }
    );
    if ( $res->{status} != 204 ) {
        $log->errorf(
            "Could not send %i lines to influx: %s",
            scalar @buffer,
            $res->{body}
        );
    }
    @buffer = ();
}

sub add_tags_to_line {
    my ( $self, $line ) = @_;

    my ( $measurment, $values, $tags, $timestamp ) = line2data($line);
    my $combined_tags;
    if ($tags) {
        $combined_tags = { %$tags, %{ $self->tags } };
    }
    else {
        $combined_tags = $tags;
    }
    return data2line( $measurment, $values, $combined_tags, $timestamp );
}

__PACKAGE__->meta->make_immutable;
1;
