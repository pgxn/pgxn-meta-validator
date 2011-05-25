use strict;
use warnings;
use Module::Build;

Module::Build->new(
    module_name        => 'PGXN::Meta::Validator',
    license            => 'perl',
    create_makefile_pl => 'traditional',
    configure_requires => { 'Module::Build' => '0.30' },
    build_requires     => {
        'Module::Build' => '0.30',
        'Test::More'    => '0.88',
    },
    requires => {
        'Carp'   => 0,
        'JSON'   => 0,
        'perl'   => 5.010,
        'SemVer' => '0.2.0',
    },
    recommends => {
        'Test::Pod'           => '1.41',
        'Test::Pod::Coverage' => '1.06',
    },
    meta_merge => {
        resources => {
            homepage   => 'http://search.cpan.org/dist/PGXN-Meta-Validator/',
            bugtracker => 'http://github.com/theory/pgxn-meta-validator/issues/',
            repository => 'http://github.com/theory/pgxn-meta-validator/tree/',
        }
    },
)->create_build_script;
