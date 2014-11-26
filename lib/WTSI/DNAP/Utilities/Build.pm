#########
# Created by:       kt6
# Created on:       1 April 2014

package WTSI::DNAP::Utilities::Build;

use strict;
use warnings;
use File::Find;
use Carp qw(carp cluck croak);
use English qw(-no_match_vars);
use Module::Load;

use base 'Module::Build';

our $VERSION           = '';
our $DEFAULT_VERSION   = '0.0';
our $DIST_VERSION_FILE = 'VERSION';

=head2 is_dist

  Example    : $build->is_dist
  Description: Return true if in an untarred distribution directory, false
               if in a respository.

  Returntype : Bool

=cut

sub is_dist {
  my ($self) = @_;

  return -e $DIST_VERSION_FILE;
}

=head2 is_repo

  Example    : $build->is_repo
  Description: Return true if in an untarred respository directory, false
               if in a distribution.

  Returntype : Bool

=cut

sub is_repo {
  my ($self) = @_;

  return !$self->is_dist;
}

=head2 report_version

  Example    : $build->report_version
  Description: Report the current version from the VERSION file (if in
               a distribution) or from git (if in a repository). This
               is a safe method for builds to populate 'dist_version'.

  Returntype : Str

=cut

sub report_version {
  my ($self) = @_;

  my $version = $DEFAULT_VERSION;
  if ($self->is_dist) {
    open my $fh, '<', $DIST_VERSION_FILE or
      die "Failed to open $DIST_VERSION_FILE for reading: $!\n";
    $version = <$fh>;
    chomp $version;
    close $fh or carp "Failed to clode $DIST_VERSION_FILE cleanly\n";
  }
  else {
    $version = $self->git_tag;
  }

  return $version;
}

sub git_tag {
  my ($self) = @_;
  my $version;

  if (`which git`) {
    $version = `git describe --dirty --always`;
    chomp $version;
  } else {
    carp "git command not found; cannot generate version string, " .
      "defaulting to $DEFAULT_VERSION";
    $version = $DEFAULT_VERSION;
  }

  unless ($version =~ /^\d+([.]\d+)?(-\S+)?/sxm) {
    carp "git version string $version not in canonical format, " .
      "defaulting to $DEFAULT_VERSION-$version";
    $version = "$DEFAULT_VERSION-$version";
  }

  return $version;
}

##no critic (NamingConventions::Capitalization)
sub ACTION_code {
  my ($self) = @_;

  $self->SUPER::ACTION_code;

  # If this is a repository, set the blib version from git
  if ($self->is_repo) {
    $self->_set_version(qw(blib/lib blib/script));
  }

  return $self;
}
##use critic

##no critic (NamingConventions::Capitalization)
sub ACTION_dist {
  my ($self) = @_;

  # Populate a new untarred distribution directory
  $self->SUPER::ACTION_distdir;

  my $dist_dir = $self->dist_dir;
  my $version_file = "$dist_dir/$DIST_VERSION_FILE";

  print "Creating dist version file $version_file\n";
  open my $fh, '>', $version_file or
    die "Failed to open $version_file for writing: $!\n";
  print $fh $self->dist_version, "\n";
  close $fh or carp "Failed to close $version_file cleanly\n";

  # If this is a repository, set the dist version from git
  if ($self->is_repo) {
    $self->_set_version($dist_dir);
  }

  $self->make_tarball($dist_dir);
  $self->delete_filetree($dist_dir);

  return $self;
}
##use critic

sub _set_version {
  my ($self, @dirs) = @_;
  @dirs = grep { -d } @dirs;

  if (@dirs) {
    warn "Changing version of all modules and scripts to '" .
      $self->dist_version . "'\n";

    find({'follow'   => 0,
          'no_chdir' => 1,
          'wanted'   => sub {
            my $module = $File::Find::name;

            if (-f $module) {
              my $backup = '.original';
              local $INPLACE_EDIT = $backup;
              local @ARGV = ($module);

              while (my $line = <>) {
                $self->_transform($line);
              }

              unlink "$module$backup";
            }
          }
         }, @dirs);
  }

  return $self;
}

sub _transform {
  my ($self, $line) = @_;
  my $version = $self->dist_version;

  ##no critic (RequireExtendedFormatting RequireLineBoundaryMatching)
  ##no critic (RequireDotMatchAnything ProhibitUnusedCapture)
  $line =~ s/(\$VERSION\s*=\s*)('?\S+'?)\s*;/${1}'$version';/;
  $line =~ s/head1 VERSION$/head1  VERSION\n\n$version/;
  print $line or croak 'Cannot print';

  return;
}

1;

__END__

=head1 NAME

 WTSI::DNAP::Utilities::Build

=head1 SYNOPSIS

 # in your Build.PL
 use WTSI::DNAP::Utilities::Build
 # then use WTSI::DNAP::Utilities::Build as you would normally use
 # Module::Build

=head1 DESCRIPTION

 This module extends Module::Build. It uses "git describe" command to
 get git tag as a base for the version. It extends the ACTION_code
 method of the parent to assign the value returned by its git_tag
 method to a $VERSION variable in all modules and scripts of the
 distribution.

 It also overrides the ACTION_dist method of the parent to perform a
 similar VERSION transformation when module files are packaged for
 distribution.

 A distribution is identified by an automatically generated VERSION
 file in its root directory. This file is not included in the
 MANIFEST, but is packaged. If it is present, git is not consulted
 to determine the current version. Instead the version is read from
 this file.

 Acceptable version numbers consist of a number followed by zero or
 more numbers, each separated by a dot character.

 e.g. 10, 10.1, 0.1.0, 1.0.1.2

=head1 SUBROUTINES/METHODS

=head2 is_dist

=head2 is_repo

=head2 git_tag

=head2 ACTION_code

=head2 ACTION_dist

=head1 DIAGNOSTICS

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Module::Build

=item File::Find

=item base

=item English

=back

=head1 NAME

=head1 BUGS AND LIMITATIONS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 INCOMPATIBILITIES

=head1 AUTHOR

Marina Gourtovaia E<lt>mg8@sanger.ac.ukE<gt>
Keith James, E<lt>kdj@sanger.ac.ukE<gt>
Kate Taylor, E<lt>kt6@sanger.ac.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014 Genome Research Limited

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

=cut
