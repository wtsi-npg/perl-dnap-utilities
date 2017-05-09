package WTSI::DNAP::Utilities::Loggable::Redirected;

use strict;
use warnings;
use base 'Tie::StdHandle';
use Log::Log4perl qw(:easy);

our $VERSION = '';

sub PRINT {
  my ($self, @m) = @_;
  $Log::Log4perl::caller_depth++;
  WARN @m;
  $Log::Log4perl::caller_depth--;
  return;
}

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Loggable::Redirected

=head1 DESCRIPTION

Provides an implementatio of PRINT method for a file handle
to be used in redirection of STDERR to a Log4Perl log.

Having configured a logger, include the following into the
code:

 tie *STDERR, 'WTSI::DNAP::Utilities::Loggable::Redirected';

=head1 AUTHOR

Marina Gourtovaia <mg8@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2017 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut

