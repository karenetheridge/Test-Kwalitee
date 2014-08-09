use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

# we are testing ourselves, so we don't want this warning
BEGIN { $ENV{_KWALITEE_NO_WARN} = 1; }

# newer Module::CPANTS::Kwalitee::CpantsErrors checks $Test::Kwalitee::VERSION
BEGIN {
    require Test::Kwalitee;
    $Test::Kwalitee::VERSION = '100' unless $Test::Kwalitee::VERSION;
}

use Test::Kwalitee 'kwalitee_ok';

# these tests all pass without building the dist
my $result = kwalitee_ok(qw(has_changelog has_readme has_tests));

ok($result, 'kwalitee_ok returned true when tests pass');

ok(!Test::Builder->new->has_plan, 'there has been no plan yet');

done_testing;
