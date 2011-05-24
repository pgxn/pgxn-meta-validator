use strict;
use warnings;
use Test::More 0.88;

use PGXN::Meta;
use PGXN::Meta::Validator;
use Clone qw(clone);

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

# Valid metadata.
for my $spec (
    ['unchanged'       => sub { } ],
    ['maintainer string' => sub { shift->{maintainer} = 'David Wheeler <theory@pgxn.org>' }],
    ['license string' => sub { shift->{license} = 'postgresql' }],
    ['multiple licenses' => sub { shift->{license} = [qw(postgresql perl_5)] }],
    ['license hash' => sub { shift->{license} = { foo => 'http://foo.com' } }],
    ['multilicense hash' => sub { shift->{license} = {
        foo => 'http://foo.com',
        bar => 'http://bar.com',
    } }],
) {
    my ($desc, $sub) = @{ $spec };
    my $dm = clone $distmeta;
    $sub->($dm);
    my $pmv = PGXN::Meta::Validator->new($dm);
    ok $pmv->is_valid, "Should be valid with $desc"
        or diag "ERRORS:\n" . join "\n", $pmv->errors;
}

for my $spec (
    [
        'no name',
        sub { delete shift->{name} },
        "Missing mandatory field, 'name' (name) [Validation: 1.0.0]",
    ],
    [
        'no version',
        sub { delete shift->{version} },
        "Missing mandatory field, 'version' (version) [Validation: 1.0.0]",
    ],
    [
        'no abstract',
        sub { delete shift->{abstract} },
        "Missing mandatory field, 'abstract' (abstract) [Validation: 1.0.0]",
    ],
    [
        'no maintainer',
        sub { delete shift->{maintainer} },
        "Missing mandatory field, 'maintainer' (maintainer) [Validation: 1.0.0]",
    ],
    [
        'no license',
        sub { delete shift->{license} },
        "Missing mandatory field, 'license' (license) [Validation: 1.0.0]",
    ],
    [
        'no meta-spec',
        sub { delete shift->{'meta-spec'} },
        "Missing mandatory field, 'version' (meta-spec -> version) [Validation: 1.0.0]",
    ],
    [
        'no provides',
        sub { delete shift->{provides} },
        "Missing mandatory field, 'provides' (provides) [Validation: 1.0.0]",
    ],
    [
        'bad version',
        sub { shift->{version} = '1.0' },
        "'1.0' for 'version' is not a valid version. (version) [Validation: 1.0.0]",
    ],
    [
        'version zero',
        sub { shift->{version} = '0' },
        "'0' for 'version' is not a valid version. (version) [Validation: 1.0.0]",
    ],
    [
        'provides version 0',
        sub { shift->{provides}{pgtap}{version} = '0' },
        "'0' for 'version' is not a valid version. (provides -> pgtap -> version) [Validation: 1.0.0]",
    ],
    [
        'bad provides version',
        sub { shift->{provides}{pgtap}{version} = 'hi' },
        "'hi' for 'version' is not a valid version. (provides -> pgtap -> version) [Validation: 1.0.0]",
    ],
    [
        'bad prereq version',
        sub { shift->{prereqs}{runtime}{requires}{plpgsql} = '1.2b1' },
        "'1.2b1' for 'plpgsql' is not a valid version. (prereqs -> runtime -> requires -> plpgsql) [Validation: 1.0.0]",
    ],
    [
        'invalid key',
        sub { shift->{foo} = 1 },
        "Custom key 'foo' must begin with 'x_' or 'X_'. (foo) [Validation: 1.0.0]",
    ],
    [
        'invalid license',
        sub { shift->{license} = 'gobbledygook' },
        "License 'gobbledygook' is invalid (license -> gobbledygook) [Validation: 1.0.0]",
    ],
    [
        'invalid licenses',
        sub { shift->{license} = [ 'bsd', 'gobbledygook' ] },
        "License 'gobbledygook' is invalid (license -> gobbledygook) [Validation: 1.0.0]",
    ],
    [
        'invalid license URL',
        sub { shift->{license} = { 'foo' => 'not a URL' } },
        "'not a URL' for 'foo' does not have a URL scheme (license -> foo) [Validation: 1.0.0]",
    ],
    [
        'second invalid license URL',
        sub { shift->{license} = { 'foo' => 'http://foo.com/', bar => 'not a URL' } },
        "'not a URL' for 'bar' does not have a URL scheme (license -> bar) [Validation: 1.0.0]",
    ],
) {
    my ($desc, $sub, $err) = @{ $spec };
    my $dm = clone $distmeta;
    $sub->($dm);
    my $pmv = PGXN::Meta::Validator->new($dm);
    ok !$pmv->is_valid, "Should be invalid with $desc";
    is [$pmv->errors]->[0], $err, "Should get error for $desc";
}

done_testing;
