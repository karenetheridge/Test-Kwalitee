use strict;
use warnings;

use Test::More;
plan( skip_all => "running in a bare repository (some files missing): skipping" ) if -d '.git';
use Test::Kwalitee;
