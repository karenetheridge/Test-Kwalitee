use strict;
use warnings FATAL => 'all';

use Test::Warnings;

# we are testing ourselves, so we don't want this warning
BEGIN { $ENV{_KWALITEE_NO_WARN} = 1; }

# these tests all pass without building the dist
my @expected; BEGIN { @expected = (qw(
    has_changelog
    has_readme
    has_tests
    no_symlinks
    proper_libs
    no_pod_errors
)) }

use Test::Kwalitee tests => \@expected;

Test::Builder->new->current_test == (@expected + 1)
    or die 'ran ' . Test::Builder->new->current_test . ' tests; expected ' . (@expected + 1) . '!';

