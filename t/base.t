use strict;
use warnings;
use Test::More tests => 7;
use File::Spec;

BEGIN {
    use_ok 'PGXN::Meta::Validator' or die;
}

my $file = File::Spec->catfile(qw(t META.json));

ok my $pmv = PGXN::Meta::Validator->new(JSON->new->decode(do {
    local $/;
    open my $fh, '<:raw', $file or die "Cannot open $file: $!\n";
    <$fh>;
})), 'Construct from data structure';
ok $pmv->is_valid, 'Structure should be valid';

ok $pmv = PGXN::Meta::Validator->load_file($file), 'Load from file';
ok $pmv->is_valid, 'File should be valid';

local $@;
eval {
    PGXN::Meta::Validator->load_file('nonexistent');
};
like $@, qr{^load_file\(\) requires a valid, readable filename},
    'Should catch exception for nonexistent file';

eval {
    PGXN::Meta::Validator->load_file('Changes');
};
like $@, qr{^malformed JSON string},
    'Should catch exception for invalid JSON';
