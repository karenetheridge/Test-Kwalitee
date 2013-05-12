use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More;

plan( skip_all => "running in a bare repository (some files missing): skipping" ) if -d '.git';

plan skip_all => 'These tests are only for Test::Builder 0.9x'
    if Test::Builder->VERSION >= 1.005;

require Test::Kwalitee;

check_tests(
    sub { Test::Kwalitee->import( tests => [ qw( -use_strict -has_readme ) ] ) },
    [ map {
            +{
                name => $_,
                depth => 2,
                ok => 1,
                actual_ok => 1,
                type => '',
                diag => '',
            }
        }
        # this list reflects Module::CPANTS::Analyse 0.87
        # same as in t/01*, except has_readme, use_strict are missing.
        qw(
            extractable
            has_buildtool
            has_changelog
            has_manifest
            has_meta_yml
            has_tests
            no_symlinks
            proper_libs
            no_pod_errors
            has_test_pod
            has_test_pod_coverage
        )
    ],
    'explicitly excluded tests do not run',
);

# done_testing already called in Test::Kwalitee's END block
