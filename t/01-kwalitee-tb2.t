use strict;
use warnings FATAL => 'all';

use Test::Warnings;

BEGIN {
    use Test::More 0.88;
    plan skip_all => 'These tests are only for Test::Builder 1.005+'
        if Test::Builder->VERSION < 1.005;
}

use TB2::Tester;

fail('TODO: write tests using TB2');
done_testing;

