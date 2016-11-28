use strict;
use warnings;
use Test::More tests => 5;

my @subs = qw/ setup_ldap unbind_ldap find_group_ids find_primary_gid /;
use_ok('WTSI::DNAP::Utilities::LDAP', @subs);

foreach my $sub (@subs) {
    can_ok(__PACKAGE__, $sub);
}
