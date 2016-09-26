package WTSI::DNAP::Utilities::ConfigureLoggerTest;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More tests => 12;
use Test::Exception;
use Log::Log4perl;
use Log::Log4perl::Level;
use File::Temp qw/tempdir/;

BEGIN { use_ok('WTSI::DNAP::Utilities::ConfigureLogger'); }

use WTSI::DNAP::Utilities::ConfigureLogger qw/most_verbose/;

Log::Log4perl::init('./etc/log4perl_tests.conf');

my $log = Log::Log4perl->get_logger('main');
my $info_string = 'Testing log info output';
my $debug_string = 'Testing log debug output';

# Note: Log::Log4perl is not designed to be initialized more than once.
# As a workaround, some tests are run by calling a command-line script.

my $log_script = './t/bin/test_log_config.pl';

sub init_from_config_file : Test(3) {

    # configure from log4perl config file
    my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
    my $log_path = $tmp."/init_from_config_file.log";
    my $embedded_conf = q(
        log4perl.logger               = INFO, A1
        log4perl.appender.A1          = Log::Log4perl::Appender::File
        log4perl.appender.A1.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.A1.layout.ConversionPattern = %d %-5p %c %M - %m%n
        log4perl.appender.A1.filename = ).$log_path.q(
        log4perl.appender.A1.utf8     = 1
    );

    my $config_path = $tmp."/log4perl.conf";
    open(my $out, '>', $config_path) ||
        $log->logcroak("Cannot open temporary logconf path '",
                       $config_path, "': $!");
    print $out $embedded_conf;
    close $out ||
        $log->logcroak("Cannot close temporary logconf path '",
                       $config_path, "': $!");

    my $cmd = "$log_script --config $config_path 2> /dev/null";

    ok(system($cmd)==0, "Command '$cmd' exit status OK");

    ok(system("grep '$info_string' $log_path > /dev/null") == 0,
       'Info output found');

    ok(system("grep '$debug_string' $log_path > /dev/null") != 0,
       'Debug output not found at info level');
}

sub init_from_output_path : Test(3) {
    # configure with output file path
    my $tmp = tempdir('ConfigureLoggerTest_XXXXXX', CLEANUP => 1);
    my $log_path = $tmp."/init_from_output_path.log";

    my $cmd = "$log_script --output $log_path --verbose 2> /dev/null";
    ok(system($cmd)==0, "Command '$cmd' exit status OK");

    ok(system("grep '$info_string' $log_path > /dev/null") == 0,
       'Info output found');

    ok(system("grep '$debug_string' $log_path > /dev/null") != 0,
       'Debug output not found at info level');
 }

sub verbosity : Test(5) {
    my @levels = ($DEBUG, $INFO, $WARN);
    ok(most_verbose(\@levels) == $DEBUG, 'Most verbose is DEBUG');
    shift @levels;
    ok(most_verbose(\@levels) == $INFO, 'Most verbose is INFO');
    push @levels, $TRACE;
    ok(most_verbose(\@levels) == $TRACE, 'Most verbose is TRACE');
    ok(most_verbose() == $ERROR, 'Default verbosity is ERROR');
    # test with illegal string input, suppressing warnings to STDERR
    my $bad_input_verbosity;
    do {
        local *STDERR;
        open (STDERR, '>', '/dev/null');
        $bad_input_verbosity = most_verbose(['debug']);
    };
    ok($bad_input_verbosity == $ERROR, 'Verbosity with bad input is ERROR');
}


1;
