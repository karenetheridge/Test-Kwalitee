use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Warnings 0.009 ':no_end_test', ':all';

# newer Module::CPANTS::Kwalitee::CpantsErrors checks $Test::Kwalitee::VERSION
BEGIN {
    require Test::Kwalitee;
    $Test::Kwalitee::VERSION = '100' unless $Test::Kwalitee::VERSION;
}

# we explicitly DO want to see warnings here...
delete local @ENV{qw(_KWALITEE_NO_WARN AUTHOR_TESTING RELEASE_TESTING)};

my @warnings = warnings {
    subtest 'no %ENV, running from t/' => sub {
        Test::Kwalitee->import(tests => [ 'has_tests' ])
    };
};

cmp_deeply(
    \@warnings,
    [ "These tests should not be running unless AUTHOR_TESTING=1 and/or RELEASE_TESTING=1!\n" ],
    'warning is issued when there is no environment guard',
) or diag 'got warnings: ', explain \@warnings;

@warnings = warnings { subtest 'no %ENV, running from xt/' => sub { do 'xt/warnings.t' } };
cmp_deeply(
    \@warnings,
    [ ],
    'no warnings issued with no environment guard from an xt/ test',
) or diag 'got warnings: ', explain \@warnings;

had_no_warnings if $ENV{AUTHOR_TESTING};
done_testing;
