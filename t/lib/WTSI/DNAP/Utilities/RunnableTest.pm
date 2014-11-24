
package WTSI::DNAP::Utilities::RunnableTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 3;
use Test::Exception;

BEGIN { use_ok('WTSI::DNAP::Utilities::Runnable'); }

use WTSI::DNAP::Utilities::Runnable;

sub run : Test(2) {
  my $runnable = WTSI::DNAP::Utilities::Runnable->new
    (executable => './t/bin/true.sh');

  is($runnable->executable, './t/bin/true.sh');
  ok($runnable->run);
}

1;
