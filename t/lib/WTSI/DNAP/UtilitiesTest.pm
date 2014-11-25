
package WTSI::DNAP::UtilitiesTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 2;
use Test::Exception;
use Log::Log4perl;

BEGIN { use_ok('WTSI::DNAP::Utilities'); }

sub version : Test(1) {
  ok($WTSI::DNAP::Utilities::VERSION);
}

1;
