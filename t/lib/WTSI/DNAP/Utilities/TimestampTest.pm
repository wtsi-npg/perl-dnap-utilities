package WTSI::DNAP::Utilities::TimestampTest;

use strict;
use warnings;
use base qw(Test::Class);
use Test::More;
use Test::Exception;
use DateTime;

 use WTSI::DNAP::Utilities::Timestamp qw/create_current_timestamp
                                         create_timestamp
                                         parse_timestamp/;

sub generate : Test(3) {
  my $pattern = qr/\A20\d\d-\d\d-\d\dT\d\d:\d\d:\d\d[-|+]/;
  like (create_current_timestamp(), $pattern, 'correct string pattern');
  like (create_current_timestamp('America/Chicago'),
    $pattern, 'correct string pattern');
  like (create_timestamp(DateTime->now()), $pattern, 'correct string pattern');
}

sub parse : Test(5) {
  throws_ok { parse_timestamp('2019-05-27T03:08:57') }
    qr/Your datetime does not match your pattern/,
    'error if the timestamp string does not conform to expected format';
  my $obj;
  lives_ok { $obj = parse_timestamp('2019-05-27T03:08:57+0100') }
    'no error parsing';
  isa_ok ($obj, 'DateTime');
  my $now = DateTime->now();
  $now->set_time_zone('local');
  is ($obj->time_zone->name, $now->time_zone->name, 'time zone is set correctly');
  
  $obj = parse_timestamp('2019-05-27T03:08:57+0100', 'America/Chicago');
  is ($obj->time_zone->name, 'America/Chicago', 'time zone is set correctly');
}

1;
