#!/software/bin/perl

use utf8;

package main;

use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl::Level;
use WTSI::DNAP::Utilities::ConfigureLogger qw/log_init/;

our $VERSION = '';

run() unless caller();

sub run {

    my $debug;
    my $log_config_path;
    my $log_output_path;
    my $verbose;

    GetOptions(
        'debug'        => \$debug,
        'config=s'     => \$log_config_path,
        'output=s'     => \$log_output_path,
        'verbose'      => \$verbose,
    );

    my @log_levels;
    if ($debug) { push @log_levels, $DEBUG; }
    if ($verbose) { push @log_levels, $INFO; }
    log_init($log_config_path, $log_output_path, \@log_levels);
    my $log = Log::Log4perl->get_logger('main');

    $log->debug("Testing log debug output");
    $log->info("Testing log info output");
    exit(0);
}

__END__

=head1 NAME

test_log_config.pl

=head1 DESCRIPTION

Script to test log configuration. Sidesteps problems with initialising
log4perl more than once within a test class. Not intended to be run except
by the WTSI::DNAP::Utilities::ConfigureLoggerTest class.

=head1 AUTHOR

Iain Bancarz <ib5@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2016 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
