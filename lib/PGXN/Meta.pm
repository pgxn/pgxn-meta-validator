package PGXN::Meta;

use 5.010;
use strict;
use Carp qw(croak);
use JSON ();
use PGXN::Meta::Prereqs;
use PGXN::Meta::Validator;

our $VERSION = v0.10.0;

sub _new {
    my ($class, $struct, $options) = @_;

    # validate struct
    my $pmv = PGXN::Meta::Validator->new( $struct );
    unless ( $pmv->is_valid) {
        die "Invalid metadata structure. Errors: "
            . join(", ", $pmv->errors) . "\n";
    }

    return bless $struct, $class;
}

sub new {
    my ($class, $struct, $options) = @_;
    my $self = eval { $class->_new($struct, $options) };
    croak($@) if $@;
    return $self;
}

sub load_file {
  my ($class, $file, $options) = @_;

  croak "load_file() requires a valid, readable filename"
    unless -r $file;

  my $self;
  eval {
      my $json = JSON->new;
      my $struct = $json->decode(do {
          local $/;
          open my $fh, '<:raw', $file or croak "Cannot open $file: $!\n";
          <$fh>;
      });
      $self = $class->_new($struct, $options);
  };
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

=head2 Constructors

=head3 C<new>

  my $meta = PGXN::Meta->new($data);

Constructs and returns a new PGXN::Meta object. Pass in a hash reference of
the metadata. If the metadata is invalid, an exception will be thrown.

=head3 C<load_file>

  my $meta = PGXN::Meta->load_file('META.json');

Reads in the specified JSON file and uses it to construct and return a new
PGXN::Meta object. If the metadata is invalid, an exception will be thrown.

=head2 Accessors

=head3 C<abstract>

  my $abstract = $meta->abstract;

Returns the abstract.

=head3 C<description>

  my $description = $meta->description;

Returns the description.

=head3 C<generated_by>

  my $generated_by = $meta->generated_by;

Returns the generated_by field value.

=head3 C<name>

  my $name = $meta->name;

Returns the name.

=head3 C<release_status>

  my $release_status = $meta->release_status;

Returns the release status.

=head3 C<version>

  my $version = $meta->version;

Returns the version.

=head3 C<maintainer>

  my @maintainer = $meta->maintainer;

Returns the list of maintainers.

=head3 C<maintainers>

  my @maintainer = $meta->maintainers;

An alias for C<maintainer>.

=head3 C<tags>

  my @tags = $meta->tags;

Returns the list of tags.

=head3 C<license>

  my $license = $meta->license;

Returns the list of licenses.

=head3 C<licenses>

  my @license = $meta->licenses;

An alias for C<license>.

=head3 C<meta_spec>

  my $meta_spec = $meta->meta_spec;

Returns a hashref containing the meta spec data.

=head3 C<resources>

  my $resources = $meta->resources;

Returns a hashref containing the resources data.

=head3 C<provides>

  my $provides = $meta->provides;

Returns a hashref containing the provides data.

=head3 C<no_index>

  my $no_index = $meta->no_index;

Returns a hashref containing the "no index" data.

=head3 C<prereqs>

  my $prereqs = $meta->prereqs;

Returns a hashref containing the prerequisites data.

=head3 C<meta_spec_version>

  my $meta_spec_version = $meta->meta_spec_version;

Returns the meta spec version.

=head2 Instance Methods

=head3 C<as_struct>

  my $data = $meta->as_struct;

Returns the metadata as a hash reference.

=head3 C<TO_JSON>

  my $json = $meta->TO_JSON;

Returns the metadata as JSON.

=head3 C<effective_prereqs>

my $prereqs = $meta->effective_prereqs;

Returns a L<PGXN::Meta::Prereqs> object encapsulating the prerequisites. This
object is useful for programmatically modifying the prerequisites.

=head3 C<custom_keys>

  my @custom_keys = $meta->custom_keys;

Returns a list of the custom keys in the top-level of the metadata.

=head3 C<custom>

  my $val = $meta->custom($custom_key);

Returns the value for a custom key in the top-level of the metadata.

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

=head1 To Do

=over

=item *

Modify the C<license> accessor to properly handle a hash reference value as
well as a list.

=item *

Add L<SemVer> support to L<Version::Requirements>

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
