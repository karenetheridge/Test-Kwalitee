#!perl

BEGIN { require 5.00602 }
use Module::Build;

my $build = Module::Build->new(
    dist_abstract => 'Test the quality of your distribution, automatically!',
    module_name   => 'Test::Kwalitee',
    license       => 'perl',
    requires      =>
    {
        'perl'                      => '5.6.2',
        'Test::Simple'              =>  '0.47',
        'Module::CPANTS::Analyse'   =>  '0.82',
    },
    meta_merge   =>
    {
        resources =>
        {
            repository => 'http://onyxneon.svnrepository.com/svn/chromatic_cpan/trunk/Test-Kwalitee/',
        }
    }
);

$build->create_build_script();
