{
  package WTSI::DNAP::Utilities::StartableThing;

  use strict;
  use warnings;

  use Moose;

  with 'WTSI::DNAP::Utilities::Startable';
}

package WTSI::DNAP::Utilities::StartableTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 6;
use Test::Exception;

BEGIN { use_ok('WTSI::DNAP::Utilities::Startable'); }

use WTSI::DNAP::Utilities::StartableThing;

Log::Log4perl::init('./etc/log4perl_tests.conf');

sub start_stop : Test(5) {
  my $exec = '/bin/cat';
  my $args = ['-'];
  my $startable = WTSI::DNAP::Utilities::StartableThing->new
    (executable => $exec,
     arguments  => $args);

  my $input = 'aaaaaaaaaa';
  is($exec, $startable->executable, 'Executable is correct');
  is_deeply($args, $startable->arguments, 'Arguments are correct')
    or explain diag $args, $startable->arguments;
  ok($startable->start, 'Can start');

  ${$startable->stdin} .= sprintf("%s", $input); # copy ofinput
  ${$startable->stdout} .= '';
  $startable->harness->pump until ${$startable->stdout};

  is(${$startable->stdout}, $input, 'Output equals input');
  ok($startable->stop, 'Can stop');
}

1;
