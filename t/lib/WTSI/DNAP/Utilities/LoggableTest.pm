{
  package WTSI::DNAP::Utilities::BasicThing;

  use strict;
  use warnings;
  use Carp;
  use Moose;

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


{
  package WTSI::DNAP::Utilities::LoggableThing;

  use strict;
  use warnings;
  use Moose;

  extends 'WTSI::DNAP::Utilities::BasicThing';
  with 'WTSI::DNAP::Utilities::Loggable';
}

{
  package WTSI::DNAP::Utilities::LoggableRedirectableThing;

  use strict;
  use warnings;
  use Moose;

  extends 'WTSI::DNAP::Utilities::BasicThing';
  with 'WTSI::DNAP::Utilities::Loggable'  => { stderr2log => 1 };
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

sub test_loggable : Test(40) {
  my $thing_default  = WTSI::DNAP::Utilities::LoggableThing->new;
  my $thing_redirected = WTSI::DNAP::Utilities::LoggableRedirectableThing->new;

  for my $thing (($thing_default, $thing_redirected)) {

    my $class         = ref $thing;
    my $default_class = 'WTSI::DNAP::Utilities::LoggableThing';

    for my $level (qw/trace debug info warn error fatal/) {
      ok($thing->$level("Log $level"), "$class can $level");
    }

    for my $method (qw/print2stderr printf2stderr/) {
      $thing->$method();
      my @lines = read_file( 'tests.log' );
      my $last_entry = pop @lines;
      my $output = qr/My printing to STDERR/;
      if ($class eq $default_class) {
        unlike ($last_entry, $output, "$class output is not in the log");
      } else {
        like ($last_entry, $output, "$class output is in the log"); 
      }
    }    

    for my $method (qw/croak2stderr_caught die2stderr_caught/) {
      lives_ok {$thing->$method()} "$class $method lives";
      my @lines = read_file( 'tests.log' );
      my $last_entry = pop @lines;
      unlike ($last_entry, qr/My caught croak|die/, "$class output is not in the log");
    }

    for my $method (qw/warn2stderr carp2stderr/) {
      $thing->$method();
      my @lines = read_file( 'tests.log' );
      my $last_entry = pop @lines;
      my $w = qr/My warning|carp/;
      if ($class eq $default_class) {
        unlike ($last_entry, $w, "$class output is not in the log");
      } else {
        like ($last_entry, $w, "$class output is in the log"); 
      }
      warning_like {$thing->$method()} $w, "it's still a warning";
    }
 
    for my $method (qw/croak2stderr die2stderr/) {
      my $error = qr/My uncaught croak|die/;
      throws_ok {$thing->$method()} $error, "error caught calling $class $method";
      my @lines = read_file( 'tests.log' );
      my $last_entry = pop @lines;
      unlike ($last_entry, $error, "error output is not in the log since captured in test");      
    }
  }
}

