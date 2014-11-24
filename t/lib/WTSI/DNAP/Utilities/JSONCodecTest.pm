{
  package WTSI::DNAP::Utilities::JSONCodecThing;

  use strict;
  use warnings;

  use Moose;

  with 'WTSI::DNAP::Utilities::JSONCodec';
}

package WTSI::DNAP::Utilities::JSONCodecTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 4;
use Test::Exception;
use Log::Log4perl;

BEGIN { use_ok('WTSI::DNAP::Utilities::JSONCodec'); }

use WTSI::DNAP::Utilities::JSONCodecThing;

Log::Log4perl::init('./etc/log4perl_tests.conf');

my $json = '{"foo":"bar"}';
my $perl = {foo => 'bar'};

sub decode : Test(2) {
  my $codec = WTSI::DNAP::Utilities::JSONCodecThing->new(max_size => 13);
  my $decoded = $codec->decode($json);
  is_deeply($decoded, $perl) or diag explain $decoded, $perl;

  dies_ok {
    WTSI::DNAP::Utilities::JSONCodecThing->new(max_size => 12)->decode($json);
    } "Exceeds maximum size";
}

sub encode : Test(1) {
  my $codec = WTSI::DNAP::Utilities::JSONCodecThing->new;
  my $encoded = $codec->encode($perl);
  is_deeply($encoded, $json) or diag explain $encoded, $json;
}

1;
