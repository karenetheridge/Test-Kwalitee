use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More 0.88;
use Test::Deep;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

my ($premature, @results) = run_tests(
    sub {
        # prevent Test::Kwalitee from making a plan
        no warnings 'redefine';
        local *Test::Builder::plan = sub { };
        local *Test::Builder::done_testing = sub { };

        # we are testing ourselves, so we don't want this warning
        local $ENV{_KWALITEE_NO_WARN} = 1;

        chdir 't/corpus';

        require Test::Kwalitee;
        Test::Kwalitee->import( tests => [ qw(has_changelog) ] );
    },
);

cmp_deeply(
    \@results,
    [
        superhashof({
            name => 'has_changelog',
            depth => 1,
            ok => 0,
            actual_ok => 0,
            type => '',
            diag => re(qr/^Error: The distribution ...+\nRemedy: Add a/s),
        }),
    ],
    'test fails, with diagnosis',
);

done_testing;
