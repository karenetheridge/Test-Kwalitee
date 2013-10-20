use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

plan( skip_all => "running in a bare repository (some files missing): skipping" ) if -d '.git';

plan skip_all => 'These tests are only for Test::Builder 0.9x'
    if Test::Builder->VERSION >= 1.005;

require Test::Kwalitee;

my ($premature, @results) = run_tests(
    sub {
        # prevent Test::Kwalitee from making a plan
        no warnings 'redefine';
        local *Test::Builder::plan = sub { };
        local *Test::Builder::done_testing = sub { };

        # we are testing ourselves, so we don't want this warning
        local $ENV{_KWALITEE_NO_WARN} = 1;

        Test::Kwalitee->import( tests => [ qw( -use_strict -has_readme ) ] );
    },
);

ok(
    (grep { $_->{name} eq 'has_changelog' } @results),
    'has_changelog, not excluded, did run',
);

foreach my $test_name (qw(has_readme use_strict))
{
    ok(
        !(grep { $_->{name} eq $test_name } @results),
        $test_name . ', explicitly excluded, did not run',
    );
}

done_testing;
