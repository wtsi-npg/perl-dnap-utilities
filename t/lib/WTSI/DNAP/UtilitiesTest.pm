
package WTSI::DNAP::UtilitiesTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 3;
use Test::Exception;
use Log::Log4perl;

BEGIN { use_ok('WTSI::DNAP::Utilities'); }

sub version : Test(2) {
  ok($WTSI::DNAP::Utilities::VERSION);
  is($WTSI::DNAP::Utilities::VERSION,
     $WTSI::DNAP::Utilities::Version::VERSION);
}

1;
