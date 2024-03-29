
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
                          'Keith James <kdj@sanger.ac.uk>'
                         ],
   dist_abstract      => 'WTSI DNA Pipelines Utility Library',
   dist_version       => WTSI::DNAP::Utilities::Build->report_version,
   license            => 'gpl',
   configure_requires => {
                          'Module::Build'             => ">= 0.42"
                         },
   build_requires      => {
                          'File::Slurp'               => '0',
                          'TAP::Harness'              => '>= 3.30',
                          'Test::Class'               => '>= 0.41',
                          'Test::Deep'                => '0',
                          'Test::More'                => '>= 0.98',
                          'Test::Exception'           => '>= 0.32',
                          'Test::LWP::UserAgent'      => '0',
                          'Test::Perl::Critic'        => '>= 1.02',
                          'Test::Warn'                => '0'
                         },
   requires =>           {
                          'Carp'                      => '>= 1.20',
                          'Cache::Cache'              => '>= 1.06',
                          'Class::Load'               => '>= 0.24',
                          'DateTime'                  => '0',
                          'DateTime::Format::Strptime' => '0',
                          'Encode'                    => '>= 2.42',
                          'IPC::Run'                  => '>= 0.92',
                          'JSON'                      => '>= 2.61',
                          'List::MoreUtils'           => '0',
                          'Log::Log4perl'             => '>= 1.42',
                          'LWP::UserAgent'            => '0',
                          'Moose'                     => '>= 2.1',
                          'MooseX::StrictConstructor' => '>= 0.19',
                          'Net::LDAP'                 => '>= 0.58',
                          'Readonly'                  => '0',
                          'Try::Tiny'                 => '>= 0.12',
                          'URI'                       => '0',
                          'URI::Split'                => '0'
                         });

$build->create_build_script;
