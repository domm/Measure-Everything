#!/usr/bin/env perl
use strict;
use warnings;

$|=1;
use Measure::Everything::Adapter;
Measure::Everything::Adapter->set('InfluxDB::File',file=>'test.msr');

my $name = $ARGV[0];
die "please provide a name as the first commandline param" unless $name;

my $app = SomeApp->new({ name=> $name });
use Time::HiRes qw(usleep);

my $target = 100000;
for my $i (1..$target) {
    $app->do($i);
    usleep(10);
    print "$i/$target\n" if ($i % 10000) == 0;
}

package SomeApp;
use Measure::Everything qw($stats);

sub new {
    my $class = shift;
    my $args = shift;
    return bless $args, $class;
}

sub do {
    my $self = shift;
    my $count = shift;
    $stats->write('counter',$count,{name=>$self->{name}});
}

