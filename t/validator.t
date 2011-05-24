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
    ['provides docfile' => sub { shift->{provides}{pgtap}{docfile} = 'foo/bar.txt' }],
    ['provides no abstract' => sub { delete shift->{provides}{pgtap}{abstract} }],
    ['provides custom key' => sub { shift->{provides}{pgtap}{x_foo} = 1 }],
    ['no spec url' => sub { delete shift->{'meta-spec'}{url} }],
    ['meta-spec custom key' => sub { shift->{'meta-spec'}{x_foo} = 1 }],
    ['multibyte name' => sub { shift->{name} = 'yoŭknow'}],
    ['name with dash' => sub { shift->{name} = 'foo-bar' }],
    ['no generated_by' => sub { delete shift->{generated_by} }],
    ['one tag' => sub { shift->{tags} = 'foo' }],
    ['no tags' => sub { shift->{tags} = [] }],
    ['no index file' => sub { shift->{no_index}{file} = ['foo']} ],
    ['no index empty file' => sub { shift->{no_index}{file} = []} ],
    ['no index file string' => sub { shift->{no_index}{file} = 'foo'} ],
    ['no index directory' => sub { shift->{no_index}{directory} = ['foo']} ],
    ['no index empty directory' => sub { shift->{no_index}{directory} = []} ],
    ['no index directory string' => sub { shift->{no_index}{directory} = 'foo'} ],
    ['no index file and directory' => sub { shift->{no_index} = {
        file => [qw(foo bar)],
        directory => 'baz',
    }}],
    ['no index custom key' => sub { shift->{no_index}{X_foo} = 1 }],
    (map {
        my $phase = $_;
        map {
            my $rel = $_;
            [
                "$phase $rel prereq",
                sub { my $m = shift; $m->{prereqs}{$phase}{$rel} = { foo => '1.2.0' }},
            ]
        } qw(requires recommends suggests);
    } qw(configure runtime build test develop)),
    (map {
        my $op = $_;
        [
            "version range with $op operator",
            sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = "$op 1.8.0"},
        ],
        [
            "version range with unspaced $op operator",
            sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = "${op}1.8.0"},
        ],
    } qw(== != < <= > >=)),
    [
        'prereq complex version range',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = '>= 1.2.0, != 1.5.0, < 2.0.0'},
    ],
    [
        'prereq complex unspaced version range',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = '>=1.2.0,!=1.5.0,<2.0.0'},
    ],
    [
        'prereq version 0',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = 0 },
    ],
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
    [
        'no provides file',
        sub { delete shift->{provides}{pgtap}{file} },
        "Missing mandatory field, 'file' (provides -> pgtap -> file) [Validation: 1.0.0]",
    ],
    [
        'no provides version',
        sub { delete shift->{provides}{pgtap}{version} },
        "Missing mandatory field, 'version' (provides -> pgtap -> version) [Validation: 1.0.0]",
    ],
    [
        'invalid provides version',
        sub { shift->{provides}{pgtap}{version} = '1.0' },
        "'1.0' for 'version' is not a valid version. (provides -> pgtap -> version) [Validation: 1.0.0]",
    ],
    [
        'provides array',
        sub { shift->{provides} = ['pgtap', '0.24.0' ]},
        'Expected a map structure. (provides) [Validation: 1.0.0]',
    ],
    [
        'undefined provides file',
        sub { shift->{provides}{pgtap}{file} = undef },
        "Missing mandatory field, 'file' (provides -> pgtap -> file) [Validation: 1.0.0]",
    ],
    [
        'undefined provides abstract',
        sub { shift->{provides}{pgtap}{abstract} = undef },
        "value is an undefined string (provides -> pgtap -> abstract) [Validation: 1.0.0]",
    ],
    [
        'undefined provides version',
        sub { shift->{provides}{pgtap}{version} = undef },
        "Missing mandatory field, 'version' (provides -> pgtap -> version) [Validation: 1.0.0]",
    ],
    [
        'undefined provides docfile',
        sub { shift->{provides}{pgtap}{docfile} = undef },
        "No file defined for 'docfile' (provides -> pgtap -> docfile) [Validation: 1.0.0]",
    ],
    [
        'bad provides custom key',
        sub { shift->{provides}{pgtap}{woot} = 'hi' },
        "Custom key 'woot' must begin with 'x_' or 'X_'. (provides -> pgtap -> woot) [Validation: 1.0.0]",
    ],
    [
        'alt spec version',
        sub { shift->{'meta-spec'}{version} = '2.0.0' },
        "Unknown META specification, cannot validate. [Validation: 2.0.0]",
    ],
    [
        'no spec version',
        sub { delete shift->{'meta-spec'}{version}; },
        "Missing mandatory field, 'version' (meta-spec -> version) [Validation: 1.0.0]",
    ],
    [
        'bad spec URL',
        sub { shift->{'meta-spec'}{url} = 'not a url' },
        "'not a url' for 'url' does not have a URL scheme (meta-spec -> url) [Validation: 1.0.0]",
    ],
    [
        'name with newline',
        sub { shift->{name} = "foo\nbar" },
        "'foo\nbar' is not a valid term (name) [Validation: 1.0.0]",
    ],
    [
        'name with return',
        sub { shift->{name} = "foo\rbar" },
        "'foo\rbar' is not a valid term (name) [Validation: 1.0.0]",
    ],
    [
        'name with slash',
        sub { shift->{name} = "foo/bar" },
        "'foo/bar' is not a valid term (name) [Validation: 1.0.0]",
    ],
    [
        'name with backslash',
        sub { shift->{name} = "foo\\bar" },
        "'foo\\bar' is not a valid term (name) [Validation: 1.0.0]",
    ],
    [
        'name with space',
        sub { shift->{name} = "foo bar" },
        "'foo bar' is not a valid term (name) [Validation: 1.0.0]",
    ],
    [
        'short name',
        sub { shift->{name} = "f" },
        "term value must be at least 2 characters (name) [Validation: 1.0.0]",
    ],
    [
        'undefined description',
        sub { shift->{description} = undef },
        "value is an undefined string (description) [Validation: 1.0.0]",
    ],
    [
        'undefined generated_by',
        sub { shift->{generated_by} = undef },
        "value is an undefined string (generated_by) [Validation: 1.0.0]",
    ],
    [
        'undef tag',
        sub { shift->{tags} = undef },
        "Expected a list structure (tags) [Validation: 1.0.0]",
    ],
    [
        'empty tag',
        sub { shift->{tags} = '' },
        "'' is not a valid tag (tags -> <undef>) [Validation: 1.0.0]",
    ],
    [
        'empty tag item',
        sub { shift->{tags} = ['foo', ''] },
        "'' is not a valid tag (tags -> <undef>) [Validation: 1.0.0]",
    ],
    [
        'undef tag item',
        sub { shift->{tags} = ['foo', undef] },
        "value is an undefined tag (tags -> <undef>) [Validation: 1.0.0]",
    ],
    [
        'long tag',
        sub { shift->{tags} = 'x' x 257 },
        "tag value must be no more than 256 characters (tags -> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) [Validation: 1.0.0]",
    ],
    [
        'no_index empty file string',
        sub { shift->{no_index}{file} = '' },
        'value is an undefined string (no_index -> file -> <undef>) [Validation: 1.0.0]',
    ],
    [
        'no_index undef file string',
        sub { shift->{no_index}{file} = undef },
        'Expected a list structure (no_index -> file) [Validation: 1.0.0]',
    ],
    [
        'no_index empty file array string',
        sub { shift->{no_index}{file} = [''] },
        'value is an undefined string (no_index -> file -> <undef>) [Validation: 1.0.0]',
    ],
    [
        'no_index undef file array string',
        sub { shift->{no_index}{file} = [undef] },
        "value is an undefined string (no_index -> file -> <undef>) [Validation: 1.0.0]",
    ],
    [
        'no_index empty directory string',
        sub { shift->{no_index}{directory} = '' },
        'value is an undefined string (no_index -> directory -> <undef>) [Validation: 1.0.0]',
    ],
    [
        'no_index undef directory string',
        sub { shift->{no_index}{directory} = undef },
        'Expected a list structure (no_index -> directory) [Validation: 1.0.0]',
    ],
    [
        'no_index empty directory array string',
        sub { shift->{no_index}{directory} = [''] },
        'value is an undefined string (no_index -> directory -> <undef>) [Validation: 1.0.0]',
    ],
    [
        'no_index undef directory array string',
        sub { shift->{no_index}{directory} = [undef] },
        "value is an undefined string (no_index -> directory -> <undef>) [Validation: 1.0.0]",
    ],
    [
        'no_index bad key',
        sub { shift->{no_index}{foo} = ['hi'] },
        "Custom key 'foo' must begin with 'x_' or 'X_'. (no_index -> foo) [Validation: 1.0.0]",
    ],
    [
        'prereq undef version',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = undef },
        "'<undef>' for 'PostgreSQL' is not a valid version. (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'prereq invalid version',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = '1.0' },
        "'1.0' for 'PostgreSQL' is not a valid version. (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'prereq undef version',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = undef },
        "'<undef>' for 'PostgreSQL' is not a valid version. (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'prereq invalid version op',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = '= 1.0.0' },
        "'=' for 'PostgreSQL' is not a valid version range operator (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'prereq wtf version op',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = '*** 1.0.0' },
        "'***' for 'PostgreSQL' is not a valid version range operator (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'prereq verersion leading comma',
        sub { shift->{prereqs}{runtime}{requires}{PostgreSQL} = ',1.0.0' },
        "'<undef>' for 'PostgreSQL' is not a valid version. (prereqs -> runtime -> requires -> PostgreSQL) [Validation: 1.0.0]",
    ],
    [
        'invalid prereq phase',
        sub { shift->{prereqs}{howdy}{requires}{PostgreSQL} = '1.0.0' },
        "Key 'howdy' is not a legal phase. (prereqs -> howdy) [Validation: 1.0.0]",
    ],
    [
        'invalid prereq phase',
        sub { shift->{prereqs}{runtime}{wanking}{PostgreSQL} = '1.0.0' },
        "Key 'wanking' is not a legal prereq relationship. (prereqs -> runtime -> wanking) [Validation: 1.0.0]",
    ],
    [
        'non-map prereq',
        sub { shift->{prereqs}{runtime}{requires} = [ PostgreSQL => '1.0.0' ] },
        "Expected a map structure. (prereqs -> runtime -> requires) [Validation: 1.0.0]",
    ],
    [
        'non-term prereq',
        sub { shift->{prereqs}{runtime}{requires}{'foo/bar'} = '1.0.0' },
        "'foo/bar' is not a valid term (prereqs -> runtime -> requires -> foo/bar) [Validation: 1.0.0]",
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
