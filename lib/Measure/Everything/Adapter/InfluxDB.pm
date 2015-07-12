package Measure::Everything::Adapter::InfluxDB;
use 5.010;
use strict;
use warnings;
use Carp qw(croak);
use Time::HiRes qw(gettimeofday);

use base qw(Measure::Everything::Adapter::Base);

sub write {
    croak "Please use a subclass of ".__PACKAGE__;
}

sub prepare_line {
    my $self = shift;
    my ($measurment, $values, $tags, $timestamp) = @_;

    if (@_ == 1) {
        # no $fields, so assume we already got a line
        return $measurment;
    }

    my $key = $measurment;
    $key=~s/([, ])/\\$1/g;

    # $tags has to be a hashref, if it's not, we dont have tags, so it's the timestampt
    if (defined $tags) {
        if (ref($tags) eq 'HASH') {
            my @tags;
            foreach my $k (sort keys %$tags) { # Influx wants the tags presorted
                my $v = $tags->{$k};
                $k=~s/([, ])/\\$1/g;
                $v=~s/([, ])/\\$1/g;
                push(@tags,$k.'='.$v);
            }
            $key.=join(',','',@tags) if @tags;
        }
        elsif (!ref($tags)) {
            $timestamp = $tags;
        }
    }

    if ($timestamp) {
        croak("$timestamp does not look like an epoch timestamp") unless $timestamp=~/^\d+$/;
        if (length($timestamp) < 19) {
            my $missing = 19 - length($timestamp);
            my $zeros = 0 x $missing;
            $timestamp.=$zeros;
        }
    }
    else {
        $timestamp = join('',gettimeofday()) * 1000;
        $timestamp*=10 if length($timestamp) <19;
    }

    # $fields can be a hashref or a scalar
    my $fields;
    my $ref_values=ref($values);
    if ($ref_values eq 'HASH') {
        my @fields;
        while (my ($k,$v) = each %$values) {
            $k=~s/([, ])/\\$1/g;
            # TODO handle booleans
            # TODO handle negative, exponentials
            if ($v=~/[^\d\.]/) {
                $v=~s/"/\\"/g;
                $v='"'.$v.'"';
            }
            push(@fields,$k.'='.$v);
        }
        $fields = join(',',@fields);
    }
    elsif (!$ref_values) {
        if ($values=~/[^\d\.]/) {
            $values=~s/([, ])/\\$1/g;
            $fields = 'value="'.$values.'"';
        }
        else {
            $fields = 'value='.$values;
        }
    }
    else {
        croak("Invalid fields $ref_values");
    }

    return sprintf("%s %s %s",$key,$fields,$timestamp);
}

1;

