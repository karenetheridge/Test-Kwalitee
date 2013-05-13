# NAME

Test::Kwalitee - test the Kwalitee of a distribution before you release it

# VERSION

version 1.06

# SYNOPSIS

    # in a separate test file
    use Test::More;

    eval { require Test::Kwalitee; Test::Kwalitee->import() };

    plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;

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

If you ship this test and a user does not have `Test::Kwalitee` installed,
nothing bad will happen.

To run only a handful of tests, pass their names to the module's `import()`
method:

    eval
    {
        require Test::Kwalitee;
        Test::Kwalitee->import( tests => [ qw( use_strict has_tests ) ] );
    };

To disable a test, pass its name with a leading minus (`-`) to `import()`:

    eval
    {
        require Test::Kwalitee;
        Test::Kwalitee->import( tests =>
            [ qw( -has_test_pod -has_test_pod_coverage ) ]
        );
    };

As of version 1.00, the tests include:

- extractable

    Is the distribution extractable?

- has\_readme

    Does the distribution have a `README` file?

- has\_manifest

    Does the distribution have a `MANIFEST`?

- has\_meta\_yml

    Does the distribution have a `META.yml` file?

- has\_buildtool

    Does the distribution have a build tool file?

- has\_changelog

    Does the distribution have a changelog?

- no\_symlinks

    Does the distribution have no symlinks?

- has\_tests

    Does the distribution have tests?

- proper\_libs

    Does the distribution have proper libs?

- no\_pod\_errors

    Does the distribution have no POD errors?

- use\_strict

    Does the distribution files all use strict?

- has\_test\_pod

    Does the distribution have a POD test file?

- has\_test\_pod\_coverage

    Does the distribution have a POD-coverage test file?

# ACKNOWLEDGEMENTS

With thanks to CPANTS and Thomas Klausner, as well as test tester Chris Dolan.

# SEE ALSO

[Module::CPANTS::Analyse](http://search.cpan.org/perldoc?Module::CPANTS::Analyse)

[Test::Kwalitee::Extra](http://search.cpan.org/perldoc?Test::Kwalitee::Extra)

# AUTHOR

chromatic <chromatic@wgz.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2005 by chromatic.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Gavin Sherlock <sherlock@cpan.org>
- Karen Etheridge <ether@cpan.org>
