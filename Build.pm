
package Build;

use strict;
use warnings;

use base 'Module::Build';

our $DEFAULT_VERSION = '0.0.0';
our $VERSION_FILE    = 'blib/lib/WTSI/DNAP/Utilities/Version.pm';

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

  my $gitver = $self->git_tag;

  if (-e $VERSION_FILE) {
    warn "Changing version of WTSI::DNAP::Utilities::Version to $gitver\n";

    my $backup  = '.original';
    local $^I   = $backup;
    local @ARGV = ($VERSION_FILE);

    while (<>) {
      s/(\$VERSION\s*=\s*)('?\S+'?)\s*;/${1}'$gitver';/;
      print;
    }

    unlink "$VERSION_FILE$backup";
  } else {
    warn "File $VERSION_FILE not found\n";
  }
}

1;
