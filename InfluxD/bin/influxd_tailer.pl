#!/usr/bin/env perl
use strict;
use warnings;
use lib::projectroot qw(lib local::lib=local);

package Runner;
use Moose;
extends 'InfluxD::FileTailer';
with 'MooseX::Getopt';

my $runner = Runner->new_with_options->run;

