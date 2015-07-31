package Measure::Everything::Adapter::Null;
use strict;
use warnings;

use base qw(Measure::Everything::Adapter::Base);

# ABSTRACT: Null Adapter: ignore all stats

sub write { }

1;

