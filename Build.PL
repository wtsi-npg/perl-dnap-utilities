
use strict;
use warnings;

# These paths are propagated to @INC in the build script. The 't/lib'
# directory is added because the Test::Class tests are there.
use lib qw(lib t/lib);

use WTSI::DNAP::Utilities::Build;

my $build = WTSI::DNAP::Utilities::Build->new
  (module_name        => 'WTSI::DNAP::Utilities',
   dist_author        => [
                          'Marina Gourtovaia <mg8@sanger.ac.uk>',
                          'Keith James <kdj@sanger.ac.uk>',
                          'Kate Taylor <kt6@sanger.ac.uk>'
                         ],
   dist_abstract      => 'WTSI DNA Pipelines Utility Library',
   dist_version       => WTSI::DNAP::Utilities::Build->report_version,
   license            => 'gpl',
   configure_requires => {
                          'Module::Build'   => ">= 0.42"
                         },
   test_requires      => {
                          'TAP::Harness'    => '>= 3.30',
                          'Test::Class'     => '>= 0.41',
                          'Test::More'      => '>= 0.98',
                          'Test::Exception' => '>= 0.32',
                         },
   requires =>           {
                          'Carp'            => '>= 1.20',
                          'Cache::Cache'    => '>= 1.06',
                          'Encode'          => '>= 2.42',
                          'IPC::Run'        => '>= 0.92',
                          'JSON'            => '>= 2.61',
                          'Log::Log4perl'   => '>= 1.42',
                          'Moose'           => '>= 2.1',
                         });

$build->create_build_script;
