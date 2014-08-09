use strict;
use warnings;
package Test::Kwalitee;
# ABSTRACT: Test the Kwalitee of a distribution before you release it
# KEYWORDS: testing tests kwalitee CPANTS quality lint errors critic
# vim: set ts=8 sw=4 tw=78 et :

use Cwd;
use Test::Builder 0.88;
use Module::CPANTS::Analyse 0.92;
use namespace::clean;

my $Test;
BEGIN { $Test = Test::Builder->new }

sub import
{
    my ($self, %args) = @_;

    warn "These tests should not be running unless AUTHOR_TESTING=1 and/or RELEASE_TESTING=1!\n"
        # this setting is internal and for this distribution only - there is
        # no reason for you to need to circumvent this check in any other context.
        # Please DO NOT enable this test to run for users, as it can fail
        # unexpectedly as parts of the toolchain changes!
        unless $ENV{_KWALITEE_NO_WARN} or $ENV{AUTHOR_TESTING} or $ENV{RELEASE_TESTING}
            or (caller)[1] =~ /^xt/;

    my @run_tests = grep { /^[^-]/ } @{$args{tests}};
    my @skip_tests = map { s/^-//; $_ } grep { /^-/ } @{$args{tests}};

    # These don't really work unless you have a tarball, so skip them
    push @skip_tests, qw(extractable extracts_nicely no_generated_files
        has_proper_version has_version manifest_matches_dist);

    # MCA has a patch to add 'needs_tarball', 'no_build' as flags
    my @skip_flags = qw(is_extra is_experimental needs_db);

    my $basedir = cwd;

    my $analyzer = Module::CPANTS::Analyse->new({
        distdir => $basedir,
        dist    => $basedir,
        # for debugging..
        opts => { no_capture => 1 },
    });

    for my $generator (@{ $analyzer->mck->generators })
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
    if (not $Test->ok( $metric->{code}->($dist), $subname))
    {
        $Test->diag('Error: ', $metric->{error});

        # NOTE: this is poking into the analyse structures; we really should
        # have a formal API for accessing this.

        # attempt to print all the extra information we have
        my @details;
        push @details, $metric->{details}->($dist)
            if $metric->{details} and ref $metric->{details} eq 'CODE';
        push @details,
            (ref $dist->{error}{$subname}
                ? @{$dist->{error}{$subname}}
                : $dist->{error}{$subname})
            if defined $dist->{error} and defined $dist->{error}{$subname};
        $Test->diag("Details:\n", join("\n", @details)) if @details;

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

=head1 METRICS

The list of each available metric currently available on your
system can be obtained with the C<kwalitee-metrics> command (with
descriptions, if you pass C<--verbose> or C<-v>, but
as of Test::Kwalitee 1.19 and L<Module::CPANTS::Analyse> 0.93_01, the tests include:

=begin :list

* has_abstract_in_pod

Does the main module have a C<=head1 NAME> section with a short description of the distribution?

* has_buildtool

Does the distribution have a build tool file?

=for stopwords changelog

* has_changelog

Does the distribution have a changelog?

* has_humanreadable_license

Is there a C<LICENSE> section in documentation, and/or a F<LICENSE> file
present?

* has_license_in_source_file

Is there license information in any of the source files?

* has_manifest

Does the distribution have a F<MANIFEST>?

* has_meta_yml

Does the distribution have a F<META.yml> file?

* has_readme

Does the distribution have a F<README> file?

* has_tests

Does the distribution have tests?

* metayml_conforms_to_known_spec

=for stopwords recognised

Does META.yml conform to any recognised META.yml specification?
(For specs see
L<http://module-build.sourceforge.net/META-spec-current.html>)

* metayml_is_parsable

Can the F<META.yml> be parsed?

* no_broken_auto_install

Is the distribution using an old version of L<Module::Install>? Versions of
L<Module::Install> prior to 0.89 do not detect correctly that C<CPAN>/C<CPANPLUS>
shell is used.

* no_broken_module_install

Does the distribution use an obsolete version of L<Module::Install>?
Versions of L<Module::Install> prior to 0.61 might not work on some systems at
all. Additionally if the F<Makefile.PL> uses the C<auto_install()>
feature, you need at least version 0.64. Also, 1.04 is known to be broken.

* no_symlinks

Does the distribution have no symlinks?

* use_strict

Does the distribution files all use strict?

=end :list

=head1 ACKNOWLEDGEMENTS

=for stopwords Klausner Dolan

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

=head1 SEE ALSO

=begin :list

* L<kwalitee-metrics> (in this distribution)
* L<Module::CPANTS::Analyse>
* L<App::CPANTS::Lint>
* L<Test::Kwalitee::Extra>
* L<Dist::Zilla::Plugin::Test::Kwalitee>
* L<Dist::Zilla::Plugin::Test::Kwalitee::Extra>
* L<Dist::Zilla::App::Command::kwalitee>

=end :list

=cut
