use strict;
use warnings;
package Test::Kwalitee;

use Cwd;
use Test::Builder;
use Module::CPANTS::Analyse 0.87;

use vars qw( $Test $VERSION );

BEGIN { $Test = Test::Builder->new() }

my %test_types;
BEGIN
{
    %test_types =
    (
        extractable           => 'distribution is extractable',
        has_readme            => 'distribution has a readme file',
        has_manifest          => 'distribution has a MANIFEST',
        has_meta_yml          => 'distribution has a META.yml file',
        has_buildtool         => 'distribution has a build tool file',
        has_changelog         => 'distribution has a changelog',
        no_symlinks           => 'distribution has no symlinks',
        has_tests             => 'distribution has tests',
        proper_libs           => 'distribution has proper libs',
        no_pod_errors         => 'distribution has no POD errors',
        use_strict            => 'distribution files all use strict',
        has_test_pod          => 'distribution has a POD test file',
        has_test_pod_coverage => 'distribution has a POD-coverage test file',
    );

# These three don't really work unless you have a tarball, so skip them for now
#        extracts_nicely       => 'distribution extracts nicely',
#        has_version           => 'distribution has a version',
#        has_proper_version    => 'distribution has a proper version',

    while (my ($subname, $diagnostic) = each %test_types)
    {
        my $sub = sub
        {
            my ($dist, $metric) = @_;
            $Test->ok( $metric->{code}->( $dist ), $subname, $diagnostic ) ||
                $Test->diag( @{ $metric }{qw( remedy error )} );
        };

        no strict 'refs';
        *{ $subname } = $sub;
    }
}

sub import
{
    my ($class, %args)   = @_;
    $args{basedir}     ||= cwd();
    $args{tests}       ||= [];
    my @tests            = @{ $args{tests} } ?
                           @{ $args{tests} } : keys %test_types;
    @tests               = keys %test_types if grep { /^-/ } @tests;

    my %run_tests;

    for my $test ( @tests, @{ $args{tests} } )
    {
        if ( $test =~ s/^-// )
        {
            delete $run_tests{$test};
        }
        else
        {
            $run_tests{$test} = 1;
        }
    }

    my $analyzer = Module::CPANTS::Analyse->new({
        distdir => $args{basedir},
        dist    => $args{basedir},
    });

    $Test->plan( tests => scalar keys %run_tests );

    for my $generator (@{ $analyzer->mck()->generators() } )
    {
        next if $generator =~ /Unpack/;
        next if $generator =~ /CPAN$/;
        next if $generator =~ /Authors$/;

        $generator->analyse($analyzer);

        for my $indicator (@{ $generator->kwalitee_indicators() })
        {
            next unless $run_tests{ $indicator->{name} };
            my $sub = __PACKAGE__->can( $indicator->{name} );
            next unless $sub;
            $sub->( $analyzer->d(), $indicator );
        }
    }
}

1;
__END__

=pod

=head1 NAME

  Test::Kwalitee - test the Kwalitee of a distribution before you release it

=head1 SYNOPSIS

  # in a separate test file
  use Test::More;

  eval { require Test::Kwalitee; Test::Kwalitee->import() };

  plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;

=head1 DESCRIPTION

Kwalitee is an automatically-measurable gauge of how good your software is.
That's very different from quality, which a computer really can't measure in a
general sense.  (If you can, you've solved a hard problem in computer science.)

In the world of the CPAN, the CPANTS project (CPAN Testing Service; also a
funny acronym on its own) measures Kwalitee with several metrics.  If you plan
to release a distribution to the CPAN -- or even within your own organization
-- testing its Kwalitee before creating a release can help you improve your
quality as well.

C<Test::Kwalitee> and a short test file will do this for you automatically.

=head1 USAGE

Create a test file as shown in the synopsis.  Run it.  It will run all of the
potential Kwalitee tests on the current distribution, if possible.  If any
fail, it will report those as regular diagnostics.

If you ship this test and a user does not have C<Test::Kwalitee> installed,
nothing bad will happen.

To run only a handful of tests, pass their names to the module's C<import()>
method:

  eval
  {
      require Test::Kwalitee;
      Test::Kwalitee->import( tests => [ qw( use_strict has_tests ) ] );
  };

To disable a test, pass its name with a leading minus (C<->) to C<import()>:

  eval
  {
      require Test::Kwalitee;
      Test::Kwalitee->import( tests =>
          [ qw( -has_test_pod -has_test_pod_coverage ) ]
      );
  };



As of version 1.00, the tests include:

=over 4

=item * extractable

Is the distribution extractable?

=item * has_readme

Does the distribution have a F<README> file?

=item * has_manifest

Does the distribution have a F<MANIFEST>?

=item * has_meta_yml

Does the distribution have a F<META.yml> file?

=item * has_buildtool

Does the distribution have a build tool file?

=item * has_changelog

Does the distribution have a changelog?

=item * no_symlinks

Does the distribution have no symlinks?

=item * has_tests

Does the distribution have tests?

=item * proper_libs

Does the distribution have proper libs?

=item * no_pod_errors

Does the distribution have no POD errors?

=item * use_strict

Does the distribution files all use strict?

=item * has_test_pod

Does the distribution have a POD test file?

=item * has_test_pod_coverage

Does the distribution have a POD-coverage test file?

=back

=head1 AUTHOR

chromatic, E<lt>chromatic at wgz dot orgE<gt>

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

=head1 BUGS

No known bugs.

=head1 COPYRIGHT

Copyright (c) 2005 - 2008, chromatic.  Some rights reserved.

This module is free software; you can use, redistribute, and modify it under
the same terms as Perl 5.8.x.
