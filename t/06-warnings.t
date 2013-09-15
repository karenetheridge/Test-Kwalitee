use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Deep;
use Test::Warnings 0.005 ':all';

# newer Module::CPANTS::Kwalitee::CpantsErrors checks $Test::Kwalitee::VERSION
BEGIN {
    require Test::Kwalitee;
    $Test::Kwalitee::VERSION = '100' unless $Test::Kwalitee::VERSION;
}

# we explicitly DO want to see warnings here...
delete local @ENV{qw(_KWALITEE_NO_WARN AUTHOR_TESTING RELEASE_TESTING)};

is(
    warning {
        subtest 'no %ENV, running from t/' => sub {
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
