#!/usr/bin/env perl -w

use strict;
use warnings;
use Test::More tests => 1;
#use Test::More 'no_plan';
use utf8;

my $CLASS;
BEGIN {
    $CLASS = 'PGXN::Meta';
    use_ok $CLASS or die;
}
