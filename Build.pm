
package Build;

use strict;
use warnings;

use base 'Module::Build';

our $DEFAULT_VERSION   = '0.0.0';
our $BLIB_VERSION_FILE = 'blib/lib/WTSI/DNAP/Utilities.pm';
our $DIST_VERSION_FILE = 'lib/WTSI/DNAP/Utilities.pm';

# Git version code courtesy of Marina Gourtovaia <mg8@sanger.ac.uk>
sub git_tag {
  my $version;

  unless (`which git`) {
    warn "git command not found; cannot generate version string, " .
      "defaulting to $DEFAULT_VERSION";
    $version = $DEFAULT_VERSION;
  }

  if (!$version) {
    $version = `git describe --dirty --always`;
    chomp $version;
  }

  unless ($version =~ /^\d+\.\d+\.\d+(-\S+)?/) {
    warn "git version string $version not in canonical format, " .
      "defaulting to $DEFAULT_VERSION";
    $version = $DEFAULT_VERSION;
  }

  return $version;
}

sub ACTION_code {
  my ($self) = @_;

  $self->SUPER::ACTION_code;
  $self->_write_version($BLIB_VERSION_FILE);
}

sub ACTION_dist {
  my ($self) = @_;

  $self->SUPER::ACTION_distdir;

  my $dist_dir = $self->dist_dir;
  $self->_write_version(File::Spec->join($dist_dir, $DIST_VERSION_FILE));
  $self->make_tarball($dist_dir);
  $self->delete_filetree($dist_dir);
}

sub _write_version {
  my ($self, $version_file) = @_;

  my $gitver = $self->git_tag;

  if (-e $version_file) {
    warn "Changing version of '$version_file' to $gitver\n";

    my $backup  = '.original';
    local $^I   = $backup;
    local @ARGV = ($version_file);

    while (<>) {
      s/(\$VERSION\s*=\s*)('?\S+'?)\s*;/${1}'$gitver';/;
      print;
    }

    unlink "$version_file$backup";
  } else {
    warn "File '$version_file' not found\n";
  }
}


1;
