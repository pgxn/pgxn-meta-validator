PGXN/Meta version 0.12.2
=======================

This library's module, PGXN::Meta, provides a simple Perl interface to the PGXN
Web API. It's designed to work with any PGXN mirror or API server.

INSTALLATION

To install this module, type the following:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you don't have Module::Build installed, type the following:

    perl Makefile.PL
    make
    make test
    make install

Dependencies
------------

PGXN-Meta requires the following modules:

* perl 5.8.1

Copyright and Licence
---------------------

Copyright (c) 2011 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
