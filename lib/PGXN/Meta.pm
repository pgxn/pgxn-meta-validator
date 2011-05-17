package PGXN::Meta;

use 5.010;
use strict;
use Carp qw(croak);
use JSON ();
use PGXN::Meta::Prereqs;

our $VERSION = v0.10.0;

sub _new {
    my ($class, $struct, $options) = @_;

    # validate struct
    # my $pmv = PGXN::Meta::Validator->new( $struct );
    # unless ( $pmv->is_valid) {
    #     die "Invalid metadata structure. Errors: "
    #         . join(", ", $pmv->errors) . "\n";
    # }

    return bless $struct, $class;
}

sub new {
    my ($class, $struct, $options) = @_;
    my $self = eval { $class->_new($struct, $options) };
    croak($@) if $@;
    return $self;
}

sub _dclone {
    my $json = JSON->new;
    $json->decode($json->convert_blessed->encode(shift));
}

sub as_struct {
    _dclone shift;
}

sub TO_JSON {
  return { %{ $_[0] } };
}

BEGIN {
    my @STRING_READERS = qw(
        abstract
        description
        generated_by
        name
        release_status
        version
    );

    no strict 'refs';
    for my $attr (@STRING_READERS) {
        *$attr = sub { $_[0]{ $attr } };
    }
}

BEGIN {
    my @LIST_READERS = qw(
        maintainer
        tags
        license
    );

    no strict 'refs';
    for my $attr (@LIST_READERS) {
        *$attr = sub {
            my $value = $_[0]{ $attr };
            croak "$attr must be called in list context"
                unless wantarray;
            return @{ _dclone($value) } if ref $value;
            return $value;
        };
    }
}

sub maintainers { $_[0]->maintainer }
sub licenses    { $_[0]->license    }

BEGIN {
    my @MAP_READERS = qw(
        meta-spec
        resources
        provides
        no_index
        prereqs
    );

    no strict 'refs';
    for my $attr (@MAP_READERS) {
        (my $subname = $attr) =~ s/-/_/;
        *$subname = sub {
            my $value = $_[0]{ $attr };
            return _dclone($value) if $value;
            return {};
        };
    }
}

sub meta_spec_version {
  my ($self) = @_;
  return $self->meta_spec->{version};
}

sub effective_prereqs {
    PGXN::Meta::Prereqs->new(shift->prereqs);
}

sub custom_keys {
  return grep { /^x_/i } keys %{$_[0]};
}

sub custom {
    my ($self, $attr) = @_;
    my $value = $self->{$attr};
    return _dclone($value) if ref $value;
    return $value;
}

1;
__END__

=head1 Name

PGXN::Meta - The distribution metadata for a PGXN distribution

=head1 Synopsis

  my $meta = PGXN::Meta->load_file('META.json');

  printf "testing requirements for %s version %s\n",
      $meta->name,
      $meta->version;

  my $prereqs = $meta->requirements_for('configure');

  for my $extension ($prereqs->required_extensions) {
      my $version = get_local_version($extension);

      die "missing required extension $extension" unless defined $version;
      die "version for $extension not in range"
          unless $prereqs->accepts_extension($extension, $version);
  }

=head1 Description

Software distributions released to the PGXN include a F<META.json> that
describes the distribution, its contents, and the requirements for building
and installing the distribution. The data structure stored in the F<META.json>
file is described in the L<PGXN Meta Spec|http://pgxn.org/spec/>.

PGXN::Meta provides a simple class to represent this distribution metadata (or
I<distmeta>), along with some helpful methods for interrogating that data.

The documentation below is only for the methods of the CPAN::Meta object.  For
information on the meaning of individual fields, consult the spec.

L<PGXN|http://pgxn.org> is a L<CPAN|http://cpan.org>-inspired network for
distributing extensions for the L<PostgreSQL RDBMS|http://www.postgresql.org>.
All of the infrastructure tools, however, have been designed to be used to
create networks for distributing any kind of release distributions and for
providing a lightweight static file JSON REST API. As such, PGXN::Meta should
work with any mirror that gets its data from a
L<PGXN::Manager|http://github.com/theory/pgxn-manager>-managed master server,
and with any L<PGXN::API>-powered server.

=head1 Interface



=head1 See Also

=over

=item * L<PGXN|http://pgxn.org/>

The PostgreSQL Extension Network, the reference implementation of the PGXN
infrastructure.

=item * L<PGXN::API>

Creates and serves a PGXN API implementation from a PGXN mirror.

=item * L<PGXN Meta Spec|http://pgxn.org/spec/>.

The specification document for the PGXN distribution metadata file,
F<META.json>.

=item * L<CPAN::Meta>

The inspiration for this module.

=back

=head1 Support

This module is stored in an open L<GitHub
repository|http://github.com/theory/pgxn-meta/>. Feel free to fork and
contribute!

Please file bug reports via L<GitHub
Issues|http://github.com/theory/pgxn-meta/issues/> or by sending mail to
L<bug-PGXN-Meta@rt.cpan.org|mailto:bug-PGXN-Meta@rt.cpan.org>.

=head1 Author

David E. Wheeler <david@justatheory.com>

Based on L<CPAN::Meta> by:

=over

=item * David Golden <dagolden@cpan.org>

=item * Ricardo Signes <rjbs@cpan.org>

=back

=head1 Copyright and License

Copyright (c) 2011 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
