use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More 0.88;
use Test::Deep;

plan skip_all => 'These tests are only for Test::Builder 0.9x'
    if Test::Builder->VERSION >= 1.005;

require Test::Kwalitee;

# prevent Test::Kwalitee from making a plan
{
    no warnings 'redefine';
    *Test::Builder::plan = sub { };
}

chdir 't/corpus';

my ($premature, @results) = run_tests(
    sub { Test::Kwalitee->import( tests => [ qw(has_changelog) ] ) },
);

cmp_deeply(
    \@results,
    [
        superhashof({
            name => 'has_changelog',
            depth => 2,
            ok => 0,
            actual_ok => 0,
            type => '',
            diag => re(qr/^Error: The distribution ...+\nRemedy: Add a/),
        }),
    ],
    'test fails, with diagnosis',
);

done_testing;
