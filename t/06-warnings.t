use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Deep;
use Test::Warnings ':all';

# newer Module::CPANTS::Kwalitee::CpantsErrors checks $Test::Kwalitee::VERSION
BEGIN {
    if (-d '.git')
    {
        $Test::Kwalitee::VERSION = '100';
        *Test::Kwalitee::VERSION = sub { 100 };
    }
}

# we explicitly DO want to see warnings here...
delete local @ENV{qw(_KWALITEE_NO_WARN AUTHOR_TESTING RELEASE_TESTING)};

is(
    warning {
        subtest 'no %ENV, running from t/' => sub {
            require Test::Kwalitee;
            Test::Kwalitee->import(tests => [ 'has_tests' ])
        };
    },
    "These tests should not be running unless AUTHOR_TESTING=1 and/or RELEASE_TESTING=1!\n",
    'warning is issued when there is no environment guard',
);

cmp_deeply(
    warning { subtest 'no %ENV, running from xt/' => sub { do 'xt/warnings.t' } },
    [ ],
    'no warnings issued with no environment guard from an xt/ test',
);

done_testing;
