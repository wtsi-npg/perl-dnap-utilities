package WTSI::DNAP::Utilities::RunnableTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::Exception;
use Test::More;
use Test::Deep;

use WTSI::DNAP::Utilities::Runnable;

Log::Log4perl::init('./etc/log4perl_tests.conf');

sub require : Test(1) {
  require_ok('WTSI::DNAP::Utilities::Runnable');
}

sub run : Test(2) {
  my $runnable = WTSI::DNAP::Utilities::Runnable->new
    (executable => './t/bin/true.sh');

  is($runnable->executable, './t/bin/true.sh');
  ok($runnable->run);
}

sub pipe : Test(2) {
  my $echo = WTSI::DNAP::Utilities::Runnable->new(executable => 'echo',
                                                  arguments  => ['Hello']);
  # Useless use of cat!
  my $cat = WTSI::DNAP::Utilities::Runnable->new(executable => 'cat');
  my $wc = WTSI::DNAP::Utilities::Runnable->new(executable  => 'wc');

  cmp_deeply([$echo->pipe($cat, $wc)->split_stdout],
            [re('\s*1       1       6')]);

  my $false = WTSI::DNAP::Utilities::Runnable->new(executable => 'false');
  dies_ok { $echo->pipe($cat, $false, $wc) }, 'Detects pipe failure';
}

1;