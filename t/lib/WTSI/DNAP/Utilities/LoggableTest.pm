{
  package WTSI::DNAP::Utilities::LoggableThing;

  use strict;
  use warnings;
  use Carp;
  use Moose;

  with 'WTSI::DNAP::Utilities::Loggable';

  sub print2stderr {
    print STDERR "My printing to STDERR\n";
  }
  sub printf2stderr {
    printf STDERR '%s', "My printing to STDERR\n";
  }
  sub warn2stderr {
    warn "My warning\n";
  }
  sub carp2stderr {
    carp 'My carp';
  }
  sub croak2stderr_caught {
    eval { croak 'My caught croak' };
  }
  sub croak2stderr {
    croak 'My uncaught croak';
  }
  sub die2stderr_caught {
    eval { die "My caught die\n" };
  }
  sub die2stderr {
    die "My uncaught die\n";
  }
}

package WTSI::DNAP::Utilities::LoggableTest;

use strict;
use warnings;
use File::Slurp;

use base qw(Test::Class);
use Test::More tests => 41;
use Test::Exception;
use Test::Warn;

BEGIN { use_ok('WTSI::DNAP::Utilities::Loggable'); }

Log::Log4perl::init('./etc/log4perl_tests.conf');

sub _test {
  my ($thing, $redirected) = @_;

  my $name = $redirected ? 'Loggable&Redirected' : 'Loggable';

  for my $level (qw/trace debug info warn error fatal/) {
    ok($thing->$level("Log $level"), "$name can $level");
  }

  for my $method (qw/print2stderr printf2stderr/) {
    $thing->$method();
    my @lines = read_file( 'tests.log' );
    my $last_entry = pop @lines;
    my $output = qr/My printing to STDERR/;
    if (!$redirected) {
      unlike ($last_entry, $output, "$name output is not in the log");
    } else {
      like ($last_entry, $output, "$name output is in the log"); 
    }
  }    

  for my $method (qw/croak2stderr_caught die2stderr_caught/) {
    lives_ok {$thing->$method()} "$name $method lives";
    my @lines = read_file( 'tests.log' );
    my $last_entry = pop @lines;
    unlike ($last_entry, qr/My caught croak|die/, "$name output is not in the log");
  }

  for my $method (qw/warn2stderr carp2stderr/) {
    $thing->$method();
    my @lines = read_file( 'tests.log' );
    my $last_entry = pop @lines;
    my $w = qr/My warning|carp/;
    if (!$redirected) {
      unlike ($last_entry, $w, "$name output is not in the log");
    } else {
      like ($last_entry, $w, "$name output is in the log"); 
    }
    warning_like {$thing->$method()} $w, "it's still a warning";
  }
 
  for my $method (qw/croak2stderr die2stderr/) {
    my $error = qr/My uncaught croak|die/;
    throws_ok {$thing->$method()} $error, "error caught calling $name $method";
    my @lines = read_file( 'tests.log' );
    my $last_entry = pop @lines;
    unlike ($last_entry, $error, "error output is not in the log since captured in test");      
  }
  return;
}

sub test_loggable : Test(20) {
  my $thing = WTSI::DNAP::Utilities::LoggableThing->new;
  _test($thing);
}

sub test_loggable_with_redirectiron : Test(20) {
  my $thing = WTSI::DNAP::Utilities::LoggableThing->new;
  $thing->redirect_stderr();
  _test($thing, 1);
}

