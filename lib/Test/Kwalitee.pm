use strict;
use warnings;
package Test::Kwalitee;
# ABSTRACT: test the Kwalitee of a distribution before you release it

use Cwd;
use Test::Builder 0.88;
use Module::CPANTS::Analyse 0.87;
use namespace::clean;

my $Test;
BEGIN { $Test = Test::Builder->new }

sub import
{
    my ($self, %args) = @_;

    warn "These tests should not be running unless AUTHOR_TESTING=1 and/or RELEASE_TESTING=1!\n"
        # this setting is internal and for this distribution only - there is
        # no reason for you to need to circumvent this check in any other context.
        unless $ENV{_KWALITEE_NO_WARN} or $ENV{AUTHOR_TESTING} or $ENV{RELEASE_TESTING};

    # Note: the basedir option is NOT documented, and may be removed!!!
    $args{basedir}     ||= cwd;

    my @run_tests = grep { /^[^-]/ } @{$args{tests}};
    my @skip_tests = map { s/^-//; $_ } grep { /^-/ } @{$args{tests}};

    # These don't really work unless you have a tarball, so skip them
    push @skip_tests, qw(extractable extracts_nicely no_generated_files
        has_proper_version has_version manifest_matches_dist);

    # MCA has a patch to add 'needs_tarball', 'no_build' as flags
    my @skip_flags = qw(is_extra is_experimental needs_db);

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
        @{ $analyzer->mck->generators };

    for my $generator (@generators)
    {
        $generator->analyse($analyzer);

        for my $indicator (sort { $a->{name} cmp $b->{name} } @{ $generator->kwalitee_indicators })
        {
            next if grep { $indicator->{$_} } @skip_flags;

            next if @run_tests and not grep { $indicator->{name} eq $_ } @run_tests;

            next if grep { $indicator->{name} eq $_ } @skip_tests;

            _run_indicator($analyzer->d, $indicator);
        }
    }

    $Test->done_testing;
}

sub _run_indicator
{
    my ($dist, $metric) = @_;

    my $subname = $metric->{name};

    $Test->level($Test->level + 1);
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
    $Test->level($Test->level - 1);
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
argument (either in the C<use> directive, or when calling C<import> directly):

  use Test::Kwalitee tests => [ qw( use_strict has_tests ) ];

To disable a test, pass its name with a leading minus (C<->):

  use Test::Kwalitee tests => [ qw( -use_strict has_readme ));

The list of each available metric currently available on your
system can be obtained with the C<kwalitee-metrics> command (with
descriptions, if you pass C<--verbose> or C<-v>, but
as of Test::Kwalitee 1.09 and L<Module::CPANTS::Analyse> 0.87, the tests include:

=begin :list

* buildtool_not_executable

F<Build.PL>/F<Makefile.PL> should not have an executable bit

* has_buildtool

Does the distribution have a build tool file?

=for stopwords changelog

* has_changelog

Does the distribution have a changelog?

* has_manifest

Does the distribution have a F<MANIFEST>?

* has_meta_yml

Does the distribution have a F<META.yml> file?

* has_readme

Does the distribution have a F<README> file?

* has_tests

Does the distribution have tests?

* no_symlinks

Does the distribution have no symlinks?

* metayml_is_parsable

Can the the F<META.yml> be parsed?

* metayml_has_license

Does the F<META.yml> declare a license?

=for stopwords libs

* proper_libs

Does the distribution have proper libs?

* has_working_buildtool

If using L<Module::Install>, it is at least version 0.61?

* has_better_auto_install

If using L<Module::Install>, it is at least version 0.89?

* has_humanreadable_license

Is there a C<LICENSE> section in documentation, and/or a F<LICENSE> file
present?

* no_pod_errors

Does the distribution have no POD errors?

* valid_signature

If a F<SIGNATURE> is present, can it be verified?

* use_strict

Does the distribution files all use strict?

* no_cpants_errors

Were there no errors encountered during CPANTS testing?

=end :list

=head1 ACKNOWLEDGEMENTS

=for stopwords Klausner Dolan

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

=head1 SEE ALSO

=begin :list

* L<kwalitee-metrics>
* L<Module::CPANTS::Analyse>
* L<Test::Kwalitee::Extra>
* L<Dist::Zilla::Plugin::Test::Kwalitee>

=end :list

=cut
