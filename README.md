# NAME

Test::Kwalitee - test the Kwalitee of a distribution before you release it

# VERSION

version 1.13

# SYNOPSIS

    # in a separate test file

    BEGIN {
        unless ($ENV{RELEASE_TESTING})
        {
            use Test::More;
            plan(skip_all => 'these tests are for release candidate testing');
        }
    }

    use Test::Kwalitee;

# DESCRIPTION

Kwalitee is an automatically-measurable gauge of how good your software is.
That's very different from quality, which a computer really can't measure in a
general sense.  (If you can, you've solved a hard problem in computer science.)

In the world of the CPAN, the CPANTS project (CPAN Testing Service; also a
funny acronym on its own) measures Kwalitee with several metrics.  If you plan
to release a distribution to the CPAN -- or even within your own organization
\-- testing its Kwalitee before creating a release can help you improve your
quality as well.

`Test::Kwalitee` and a short test file will do this for you automatically.

# USAGE

Create a test file as shown in the synopsis.  Run it.  It will run all of the
potential Kwalitee tests on the current distribution, if possible.  If any
fail, it will report those as regular diagnostics.

If you ship this test, it will not run for anyone else, because of the
`RELEASE_TESTING` guard. (You can omit this guard if you move the test to
xt/release/, which is not run automatically by other users.)

To run only a handful of tests, pass their names to the module in the `test`
argument (either in the `use` directive, or when calling `import` directly):

    use Test::Kwalitee tests => [ qw( use_strict has_tests ) ];

To disable a test, pass its name with a leading minus (`-`):

    use Test::Kwalitee tests => [ qw( -use_strict has_readme ));

The list of each available metric currently available on your
system can be obtained with the `kwalitee-metrics` command (with
descriptions, if you pass `--verbose` or `-v`, but
as of Test::Kwalitee 1.09 and [Module::CPANTS::Analyse](http://search.cpan.org/perldoc?Module::CPANTS::Analyse) 0.87, the tests include:

- buildtool\_not\_executable

    `Build.PL`/`Makefile.PL` should not have an executable bit

- has\_buildtool

    Does the distribution have a build tool file?

- has\_changelog

    Does the distribution have a changelog?

- has\_manifest

    Does the distribution have a `MANIFEST`?

- has\_meta\_yml

    Does the distribution have a `META.yml` file?

- has\_readme

    Does the distribution have a `README` file?

- has\_tests

    Does the distribution have tests?

- no\_symlinks

    Does the distribution have no symlinks?

- metayml\_is\_parsable

    Can the the `META.yml` be parsed?

- metayml\_has\_license

    Does the `META.yml` declare a license?

- proper\_libs

    Does the distribution have proper libs?

- has\_working\_buildtool

    If using [Module::Install](http://search.cpan.org/perldoc?Module::Install), it is at least version 0.61?

- has\_better\_auto\_install

    If using [Module::Install](http://search.cpan.org/perldoc?Module::Install), it is at least version 0.89?

- has\_humanreadable\_license

    Is there a `LICENSE` section in documentation, and/or a `LICENSE` file
    present?

- no\_pod\_errors

    Does the distribution have no POD errors?

- valid\_signature

    If a `SIGNATURE` is present, can it be verified?

- use\_strict

    Does the distribution files all use strict?

- no\_cpants\_errors

    Were there no errors encountered during CPANTS testing?

# ACKNOWLEDGEMENTS

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

# SEE ALSO

- `script/kwalitee-metrics`
- [Module::CPANTS::Analyse](http://search.cpan.org/perldoc?Module::CPANTS::Analyse)
- [Test::Kwalitee::Extra](http://search.cpan.org/perldoc?Test::Kwalitee::Extra)
- [Dist::Zilla::Plugin::Test::Kwalitee](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::Test::Kwalitee)

# AUTHORS

- chromatic <chromatic@wgz.org>
- Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2005 by chromatic.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Gavin Sherlock <sherlock@cpan.org>
- Kenichi Ishigaki <ishigaki@cpan.org>
- Nathan Haigh <nathanhaigh@ukonline.co.uk>
