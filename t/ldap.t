use strict;
use warnings;
use Test::More tests => 3;

my @methods = qw/ find_group_ids find_primary_gid /;
use_ok('WTSI::DNAP::Utilities::LDAP');

foreach my $sub (@methods) {
    can_ok(q(WTSI::DNAP::Utilities::LDAP), $sub);
}
