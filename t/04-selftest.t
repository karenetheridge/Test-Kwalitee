use strict;
use warnings FATAL => 'all';

use Test::Warnings;

# we are testing ourselves, so we don't want this warning
BEGIN { $ENV{_KWALITEE_NO_WARN} = 1; }

use Test::Kwalitee tests => [
        # these tests all pass without building the dist
        qw(
            has_changelog
            has_readme
            has_tests
            no_symlinks
            proper_libs
            no_pod_errors
        )
    ];

Test::Builder->new->current_test == 7
    or die 'ran ' . Test::Builder->new->current_test . ' tests; expected 7!';

