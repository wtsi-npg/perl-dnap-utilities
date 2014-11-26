
{
  package WTSI::DNAP::Utilities::LoggableThing;

  use strict;
  use warnings;

  use Moose;

  with 'WTSI::DNAP::Utilities::Loggable';
}

package WTSI::DNAP::Utilities::LoggableTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 7;
use Test::Exception;

BEGIN { use_ok('WTSI::DNAP::Utilities::Loggable'); }

Log::Log4perl::init('./etc/log4perl_tests.conf');

sub test_loggable : Test(6) {
  my $thing = WTSI::DNAP::Utilities::LoggableThing->new;

  ok($thing->trace('Trace'), 'Can trace');
  ok($thing->debug('Debug'), 'Can debug');
  ok($thing->info('Info'),   'Can info');
  ok($thing->warn('Warn'),   'Can warn');
  ok($thing->error('Error'), 'Can error');
  ok($thing->fatal('Fatal'), 'Can fatal');
}
