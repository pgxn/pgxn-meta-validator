#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More 0.88;

use PGXN::Meta;

use Scalar::Util qw(blessed);

my $distmeta = {
    name     => 'pgTAP',
    abstract => 'TAP-driven unit testing for PostgreSQL',
    description => 'pgTAP is a suite of database functions that make it easy '
                 . 'to write TAP-emitting unit tests in psql scripts or xUnit-'
                 . 'style test functions.',
    version  => '0.24.0',
    maintainer => [
        'David Wheeler <theory@pgxn.org>',
        'pgTAP List <pgtap-users@pgfoundry.org>'  # additional contact
    ],
    release_status => 'stable',
    license  => [ 'postgresql' ],
    prereqs => {
        runtime => {
            requires => {
                'PostgreSQL' => '8.0.0',
                'plpgsql'    => '0',
            },
            recommends => {
                'PostgreSQL' => '8.4.0',
            },
        },
        build => {
            requires => {
                'plperl' => '0',
            },
        }
    },
    resources => {
        'homepage' => 'http://pgtap.org/',
        'bugtracker' => {
            'web' => 'https://github.com/theory/pgtap/issues'
        },
        'repository' => {
            'url' =>  'https://github.com/theory/pgtap.git',
            'web' =>  'https://github.com/theory/pgtap',
            'type' => 'git'
        }
    },
    'tags' => [
        "testing",
        "unit testing",
        "tap",
        "tddd",
        "test driven database development"
    ],
    'meta-spec' => {
        version => '1.0.0',
    url     => 'http://pgxn.org/meta/spec.txt',
    },
    generated_by => 'David E. Wheeler',
    x_authority => 'cpan:FLORA',
    X_deep => { deep => 'structure' },
};

my $meta = PGXN::Meta->new($distmeta);

ok !blessed($meta->as_struct), "the result of ->as_struct is unblessed";

is_deeply( $meta->as_struct, $distmeta, "->as_struct (deep comparison)" );
isnt( $meta->as_struct, $distmeta, "->as_struct (is a deep clone)" );

my $old_copy = $meta->as_struct( {version => "1.4"} );
is( $old_copy->{'meta-spec'}{version}, "1.0.0", "->as_struct (downconversion)" );

isnt( $meta->resources, $meta->{resources}, "->resource (map values are deep cloned)");

is($meta->name,     'pgTAP', '->name');
is($meta->abstract, 'TAP-driven unit testing for PostgreSQL', '->abstract');

like($meta->description, qr/^pgTAP is a suite.+test functions\.$/, '->description');

is($meta->version,   '0.24.0', '->version');

is_deeply(
    [ $meta->maintainer ],
    [
        'David Wheeler <theory@pgxn.org>',
        'pgTAP List <pgtap-users@pgfoundry.org>',
    ],
    '->maintainer',
);

is_deeply(
    [ $meta->maintainers ],
    [
        'David Wheeler <theory@pgxn.org>',
        'pgTAP List <pgtap-users@pgfoundry.org>',
    ],
    '->maintainers',
);

is_deeply(
    [ $meta->license ],
    [ qw(postgresql) ],
    '->license',
);

is_deeply(
    [ $meta->licenses ],
    [ qw(postgresql) ],
    '->licenses',
);

is_deeply(
    [ $meta->tags ],
    [
        "testing",
        "unit testing",
        "tap",
        "tddd",
        "test driven database development"
    ],
    '->tags',
);

is_deeply(
    $meta->resources,
    {
        homepage => 'http://pgtap.org/',
        bugtracker => {
            web => 'https://github.com/theory/pgtap/issues'
        },
        repository => {
            url =>  'https://github.com/theory/pgtap.git',
            web =>  'https://github.com/theory/pgtap',
            type => 'git'
        },
    },
    '->resources',
);

is_deeply(
  $meta->meta_spec,
  {
    version => '1.0.0',
    url     => 'http://pgxn.org/meta/spec.txt',
  },
  '->meta_spec',
);

is($meta->meta_spec_version, '1.0.0', '->meta_spec_version');

is($meta->generated_by, 'David E. Wheeler', '->generated_by');

my $basic = $meta->effective_prereqs;

is_deeply(
    $basic->as_string_hash,
    $distmeta->{prereqs},
    "->effective_prereqs()"
);

is_deeply( [ sort $meta->custom_keys ] , [ 'X_deep', 'x_authority' ],
    "->custom_keys"
);

is( $meta->custom('x_authority'), 'cpan:FLORA', "->custom(X)" );

is_deeply( $meta->custom('X_deep'), $distmeta->{'X_deep'},
  "->custom(X) [is_deeply]"
);

isnt( $meta->custom('X_deep'), $distmeta->{'X_deep'},
  "->custom(x) [is a deep clone]"
);

my $with_features = $meta->effective_prereqs([ qw(domination) ]);

is_deeply(
  $with_features->as_string_hash,
  {
      runtime => {
          requires => {
              'PostgreSQL' => '8.0.0',
              'plpgsql'    => '0',
          },
          recommends => {
              'PostgreSQL' => '8.4.0',
          },
      },
      build => {
          requires => {
              'plperl' => '0',
          },
      }
  },
  "->effective_prereqs()"
);

done_testing;
