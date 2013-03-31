#!perl

use Module::Build;

my $build = Module::Build->new(
	module_name => 'Test::Kwalitee',
	license     => 'perl',
	requires    => 
	{
		'perl'                      => '5.6.1',
		'Test::Simple'              =>  '0.47',
		'Module::CPANTS::Analyse'   =>  '0.50',
	},
	create_makefile_pl => 'traditional',
	sign        => 1,
);
$build->create_build_script();
