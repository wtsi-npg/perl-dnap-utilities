package WTSI::DNAP::Utilities::Timestamp;

use strict;
use warnings;
use Exporter qw(import);
use Readonly;
use DateTime;
use DateTime::Format::Strptime;

our @EXPORT_OK = qw(create_timestamp
                    create_current_timestamp
                    parse_timestamp);

our $VERSION = '';

Readonly::Scalar my $TIMESTAMP_FORMAT_WOFFSET => q[%Y-%m-%dT%T%z];
Readonly::Scalar my $DEFAULT_TIMEZONE         => q[local];

sub create_timestamp {
  my $dt = shift;
  return $dt->strftime($TIMESTAMP_FORMAT_WOFFSET);
}

sub create_current_timestamp {
  my $zone = shift;
  $zone ||= $DEFAULT_TIMEZONE;
  return create_timestamp(DateTime->now(time_zone => $zone));
}

sub parse_timestamp {
  my ($time_string, $zone) = @_;

  $zone ||= $DEFAULT_TIMEZONE;
  my $dt = DateTime::Format::Strptime->new(
             pattern  => $TIMESTAMP_FORMAT_WOFFSET,
             strict   => 1, # match the pattern exactly
             on_error => 'croak'
  )->parse_datetime($time_string);

  $dt->set_time_zone($zone);

  return $dt;
}

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Timestamp

=head1 SYNOPSIS

=head1 DESCRIPTION

A module providing methods for generating timestamp strings compatible
with RFC 3339 with accuracy down to the level of seconds and deserializing
these strings into DateTime objects.

  use WTSI::DNAP::Utilities::Timestamp qw/ create_timestamp
                                           create_current_timestamp
                                           parse_timestamp /;
  my $ts = create_current_timestamp();

=head1 SUBROUTINES/METHODS

head2 create_current_timestamp

Creates a timestamp string for the current time using the local
time zone by default. The time zone can be changed by passing
the time zone argument.
  
  my $dt_string = create_current_timestamp();
  my $dt_string = create_current_timestamp('America/Chicago');

=head2 create_timestamp

Creates a timestamp string for the DateTime object passed as an argument.

  my $dt_string = create_timestamp($datetime_obj);

=head2 parse_timestamp

Parses the argument string and returns a DateTime object. If a time zone
string is passed as aa second  argument, the time zone of this object is
set to that time zone, otherwise the default 'local' time zone is used.

When the 'local' timezone is used, the object is localised to the time
zone on the host where this method is executed, which allows to follow
the DST time change correctly.

Errors if the argument string does not conform to the format used in
this package.

  my $date_time_obj = parse_timestamp('2019-05-27T03:08:57+0100');

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item Exporter

=item Readonly

=item DateTime

=item DateTime::Format::Strptime

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

David K. Jackson

Marina Gourtovaia

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2019 Genome Research Limited

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


