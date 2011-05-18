use strict;
use warnings;
use Test::More 0.88;

use PGXN::Meta;
use PGXN::Meta::Validator;

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
    provides => {
        pgtap => {
            abstract => "Unit testing for PostgreSQL",
            file => "pgtap.sql",
            version => "0.26.0"
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

VALID: {
    my $pmv = PGXN::Meta::Validator->new({%{ $distmeta }});
    ok $pmv->is_valid, "META 1.0.0 validates"
        or diag "ERRORS:\n" . join "\n", $pmv->errors;
}

for my $spec (
    ['no name'       => sub { delete shift->{name} } ],
    ['no version'    => sub { delete shift->{version} } ],
    ['no abstract'   => sub { delete shift->{abstract} } ],
    ['no maintainer' => sub { delete shift->{maintainer} } ],
    ['no license'    => sub { delete shift->{license} } ],
    ['no meta-spec'  => sub { delete shift->{'meta-spec'} } ],
    ['no provides'   => sub { delete shift->{provides} } ],
    ['bad version'   => sub { shift->{version} = '1.0' } ],
    ['version zero'  => sub { shift->{version} = '0' } ],
    ['provides version 0' => sub { shift->{provides}{pgtap}{version} = '0' }],
    ['bad provides version' => sub { shift->{provides}{pgtap}{version} = 'hi' }],
    ['bad prereq version' => sub {
         $_[0]->{provides}{pgtap}{version} = "0.26.0";
         shift->{prereqs}{runtime}{requires}{plpgsql} = '1.2b1';
     }],
) {
    my ($desc, $sub) = @{ $spec };
    my %dm = %{ $distmeta };
    $sub->(\%dm);
    my $pmv = PGXN::Meta::Validator->new(\%dm);
    ok !$pmv->is_valid, "Should be invalid with $desc";
}

done_testing;
