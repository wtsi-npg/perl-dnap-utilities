
package WTSI::DNAP::Utilities::JSONCodec;

use strict;
use warnings;
use JSON;
use Moose::Role;

our $VERSION = '';

# These methods are autodelegated to instances with this role.
our @HANDLED_JSON_METHODS = qw(decode encode);

has 'max_size' =>
  (is            => 'ro',
   isa           => 'Int',
   required      => 0,
   default       => 0,
   documentation => 'The default max size is 0 which indicates no limit');

has 'parser' =>
  (is       => 'ro',
   isa      => 'JSON',
   lazy     => 1,
   required => 1,
   default  => sub {
     my ($self) = @_;
     return JSON->new->utf8->max_size($self->max_size);
   },
   handles  => [@HANDLED_JSON_METHODS]);

no Moose;

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::JSONCodec

=head1 DESCRIPTION

A UTF-8 JSON codec Role.  When consumed, this role automatically
delegates encode and decode method calls to a JSON codec.

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2014, 2015 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
