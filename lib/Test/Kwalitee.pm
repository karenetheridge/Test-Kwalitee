use strict;
use warnings;
package Test::Kwalitee;
# ABSTRACT: test the Kwalitee of a distribution before you release it

use Cwd;
use Test::Builder 0.88;
use Module::CPANTS::Analyse 0.87;
use namespace::clean;

use vars qw( $Test $VERSION );

BEGIN { $Test = Test::Builder->new() }

sub import
{
    my ($self, %args) = @_;

    # Note: the basedir option is NOT documented, and may be removed!!!
    $args{basedir}     ||= cwd();

    my @run_tests = grep { /^[^-]/ } @{$args{tests}};
    my @skip_tests = map { s/^-//; $_ } grep { /^-/ } @{$args{tests}};

    # These don't really work unless you have a tarball, so skip them
    push @skip_tests, qw(extracts_nicely no_generated_files has_proper_version has_version manifest_matches_dist);

    # these tests have never been documented as being available via this dist;
    # skip for now, but in later releases we may add them
    push @skip_tests, qw(buildtool_not_executable
        metayml_conforms_to_known_spec metayml_has_license metayml_is_parsable
        has_better_auto_install has_working_buildtool
        has_humanreadable_license valid_signature no_cpants_errors);

    # these are classified as 'extra' tests, but they have always been
    # included in Test::Kwalitee (they don't belong, so we will remove them in
    # a later release)
    my @include_extra = qw(has_test_pod has_test_pod_coverage);

    my $analyzer = Module::CPANTS::Analyse->new({
        distdir => $args{basedir},
        dist    => $args{basedir},
        # for debugging..
        opts => { no_capture => 1 },
    });

    # get generators list in the order they should run, but also keep the
    # order consistent between runs
    # (TODO: remove, once MCK can itself sort properly -- see
    # https://github.com/daxim/Module-CPANTS-Analyse/pull/12)
    my @generators =
        map { $_->[1] }             # Schwartzian transform out
        sort {
            $a->[0] <=> $b->[0]     # sort by run order
                ||
            $a->[1] cmp $b->[1]     # falling back to generator name
        }
        map { [ $_->order, $_ ] }   # Schwartzian transform in
        @{ $analyzer->mck()->generators() };

    for my $generator (@generators)
    {
        $generator->analyse($analyzer);

        for my $indicator (sort { $a->{name} cmp $b->{name} } @{ $generator->kwalitee_indicators() })
        {
            next if ($indicator->{is_extra} or $indicator->{is_experimental})
                and not grep { $indicator->{name} eq $_ } @include_extra;

            next if @run_tests and not grep { $indicator->{name} eq $_ } @run_tests;

            next if grep { $indicator->{name} eq $_ } @skip_tests;

            _run_indicator($analyzer->d(), $indicator);
        }
    }

    $Test->done_testing;
}

sub _run_indicator
{
    my ($dist, $metric) = @_;

    my $subname = $metric->{name};

    if (not $Test->ok( $metric->{code}->( $dist ), $subname))
    {
        $Test->diag('Error: ', $metric->{error});

        $Test->diag('Details: ',
            (ref $dist->{error}{$subname}
                ? join("\n", @{$dist->{error}{$subname}})
                : $dist->{error}{$subname}))
            if defined $dist->{error} and defined $dist->{error}{$subname};

        $Test->diag('Remedy: ', $metric->{remedy});
    }
}

1;
__END__

=pod

=head1 SYNOPSIS

  # in a separate test file

  BEGIN {
      unless ($ENV{RELEASE_TESTING})
      {
          use Test::More;
          plan(skip_all => 'these tests are for release candidate testing');
      }
  }

  use Test::Kwalitee;

=head1 DESCRIPTION

=for stopwords CPANTS

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

If you ship this test, it will not run for anyone else, because of the
C<RELEASE_TESTING> guard. (You can omit this guard if you move the test to
xt/release/, which is not run automatically by other users.)

To run only a handful of tests, pass their names to the module in the C<test>
argument (either in the C<use> directive, or when calling C<import()> directly):

  use Test::Kwalitee tests => [ qw( use_strict has_tests ) ];

To disable a test, pass its name with a leading minus (C<->):

  use Test::Kwalitee tests => [ qw( -has_test_pod -has_test_pod_coverage ));

As of version 1.00, the tests include:

=over 4

=for stopwords extractable

=item * extractable

This test does nothing without a tarball; it will be removed in a subsequent
version.

=item * has_buildtool

Does the distribution have a build tool file?

=for stopwords changelog

=item * has_changelog

Does the distribution have a changelog?

=item * has_manifest

Does the distribution have a F<MANIFEST>?

=item * has_meta_yml

Does the distribution have a F<META.yml> file?

=item * has_readme

Does the distribution have a F<README> file?

=item * has_tests

Does the distribution have tests?

=item * no_symlinks

Does the distribution have no symlinks?

=for stopwords libs

=item * proper_libs

Does the distribution have proper libs?

=item * no_pod_errors

Does the distribution have no POD errors?

=item * has_test_pod

Does the distribution have a test for pod correctness?  (Note that this is a
bad test to include in a distribution where it will be run by users; this
check will be removed in a subsequent version.)

=item * has_test_pod_coverage

Does the distribution have a test for pod coverage?  (This test will be
removed in a subsequent version; see C<has_test_pod> above.)

=item * use_strict

Does the distribution files all use strict?

=back

=head1 ACKNOWLEDGEMENTS

=for stopwords Klausner Dolan

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

=head1 SEE ALSO

=begin :list

* L<Module::CPANTS::Analyse>
* L<Test::Kwalitee::Extra>
* L<Dist::Zilla::Plugin::Test::Kwalitee>

=end :list

=cut
