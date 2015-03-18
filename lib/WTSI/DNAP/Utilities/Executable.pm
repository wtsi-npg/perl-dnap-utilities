
package WTSI::DNAP::Utilities::Executable;

use strict;
use warnings;
use IPC::Run;;
use Moose::Role;

our $VERSION = '';

has 'stdin' =>
  (is      => 'rw',
   isa     => 'ScalarRef[Str] | FileHandle | CodeRef',
   default => sub { my $x = q{}; return \$x; });

has 'stdout' =>
  (is      => 'rw',
   isa     => 'ScalarRef[Str] | FileHandle | CodeRef',
   default => sub { my $x = q{}; return \$x; });

has 'stderr' =>
  (is      => 'rw',
   isa     => 'ScalarRef[Str] | FileHandle | CodeRef',
   default => sub { my $x = q{}; return \$x; });

has 'environment' =>
  (is      => 'ro',
   isa     => 'HashRef',
   lazy    => 1,
   default => sub { \%ENV });

has 'executable' =>
  (is       => 'ro',
   isa      => 'Str',
   required => 1);

has 'arguments' =>
  (is      => 'ro',
   isa     => 'ArrayRef',
   lazy    => 1,
   default => sub { [] });

no Moose;

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Executable

=head1 DESCRIPTION

A Role providing attributes to represent a single run of an external
program by some method of IPC.

STDIN, STDOUT and STDERR may be supplied as ScalarRefs, FileHandles or
CodeRefs (filters).

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2013, 2014 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
