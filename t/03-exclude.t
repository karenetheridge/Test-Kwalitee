use strict;
use warnings;

use Test::Builder;
use Test::More tests => 13;

require_ok( 'Test::Kwalitee' );

{
	local *Test::Builder::plan;
	*Test::Builder::plan = sub {};

	Test::Kwalitee->import( tests => [qw( -use_strict -has_readme )] );
}

my $Test = Test::Builder->new();

is( $Test->current_test(), 12, 'Explicitly excluded tests should not run' );
