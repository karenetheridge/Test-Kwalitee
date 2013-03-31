use strict;
use warnings;

use Test::More;

eval
{
	require Test::Kwalitee;
	Test::Kwalitee->import( tests => [qw( -use_strict -has_readme )] );
};

plan( skip_all => "Test::Kwalitee not installed: $@; skipping" ) if $@;
