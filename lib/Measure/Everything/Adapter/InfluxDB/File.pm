package Measure::Everything::Adapter::InfluxDB::File;
use 5.010;
use strict;
use warnings;

use Config;
use Fcntl qw/:flock/;

use base qw(Measure::Everything::Adapter::InfluxDB);

my $HAS_FLOCK = $Config{d_flock} || $Config{d_fcntl_can_lock} || $Config{d_lockf};

sub init {
    my $self = shift;
    my $file = $self->{file};
    open( $self->{fh}, ">>", $file )
      or die "cannot open '$file' for append: $!";
    $self->{fh}->autoflush(1);
}

sub write {
    my $self = shift;
    my $line = $self->prepare_line(@_);

    flock($self->{fh}, LOCK_EX) if $HAS_FLOCK;
    $self->{fh}->print($line."\n");
    flock($self->{fh}, LOCK_UN) if $HAS_FLOCK;
}

1;

