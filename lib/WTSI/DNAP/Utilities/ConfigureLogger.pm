package WTSI::DNAP::Utilities::ConfigureLogger;

use utf8;

use strict;
use warnings;
use Carp;
use Log::Log4perl;
use Log::Log4perl::Level;

use base 'Exporter';
our @EXPORT_OK = qw(log_init most_verbose);

our $VERSION = '';

our $DEFAULT_LOG_LEVEL = $ERROR;

=head2 log_init

  Arg [1]    : Maybe [Str] path to Log4perl config file
  Arg [2]    : Maybe [Str] path to output file
  Arg [3]    : Maybe [ArrayRef[Int]] Log4perl levels

  Example    : log_init($config, $logfile, $log_levels);

  Description: Initializes logging with Log4perl.

               Must supply either a log4perl config file path; or
               an output path. If the first argument is defined, the
               second and third arguments are ignored; otherwise,
               the second and third arguments are used.

               If defined, the third argument is an ArrayRef of Log4perl
               numeric level constants. Logging will be at the most verbose
               level in the ArrayRef, or a default level otherwise. See
               the most_verbose function for details.

  Returntype : True if initialization succeeded; croaks otherwise.

  Caller     : general

=cut

sub log_init {
    my ($log4perl_config, $log_path, $log_levels) = @_;
    if (defined $log4perl_config ) {
        if (! -r $log4perl_config) {
            croak("Cannot read log4perl config path '", $log4perl_config,
                  "': $!");
        }
    } elsif (! defined $log_path ) {
        croak("Must supply either a log4perl config path, ",
              "or an output path: $!");
    }
    # configure and initialise log
    if ($log4perl_config) {
        Log::Log4perl::init($log4perl_config);
    } else {
        my $level = most_verbose($log_levels);
        my @log_args = ({layout => '%d %p %m %n',
                         level  => $level,
                         file     => ">>$log_path",
                         utf8   => 1},
                        {layout => '%d %p %m %n',
                         level  => $level,
                         file   => "STDERR",
                         utf8   => 1},
                    );
        Log::Log4perl->easy_init(@log_args);
    }
    my $init_ok = Log::Log4perl->initialized();
    $init_ok || croak("Failed to initialize Log4perl: $!");
    return $init_ok;
}


=head2 most_verbose

  Arg [1]    : Maybe [ArrayRef[Int]] Log4perl levels

  Example    : $log_level = most_verbose($log_levels);

  Description: Takes an ArrayRef of zero or more numeric Log4Perl level
               constants. Returns the most verbose level input, if any. If
               the input ArrayRef is empty or undefined, a default level
               is returned.

  Returntype : [Int] Log4perl level constant

  Caller     : log_init

=cut

sub most_verbose {
    my ($levels, ) = @_;
    # array of constants from Log4perl::Level
    my @all_levels = ($ALL,
                      $TRACE,
                      $DEBUG,
                      $INFO,
                      $WARN,
                      $ERROR,
                      $FATAL,
                      $OFF);
    # warn if the input contains unexpected values
    my %all_levels;
    foreach my $level (@all_levels) { $all_levels{$level} = 1; }
    my @valid_levels;
    foreach my $level (@{$levels}) {
        if (defined $all_levels{$level}) {
            push @valid_levels, $level;
        } else {
            carp("Input value '", $level, "' is not a Log4perl numeric ",
                 "level constant, and will be ignored");
        }
    }
    # find and return the most verbose level given, or a default
    my @sorted_levels = sort _by_descending_verbosity @valid_levels;
    my $logging_level = shift @sorted_levels;
    if (! defined $logging_level ) { $logging_level = $DEFAULT_LOG_LEVEL; }
    return $logging_level;
}

sub _by_descending_verbosity {
    # comparison function for Log4perl level sort, used in most_verbose
    if ($a == $b) {
        return  0;
    } elsif (Log::Log4perl::Level::isGreaterOrEqual($a, $b)) {
        return -1; # $a > $b
    } else {
        return  1; # $a < $b
    }
}

1;


__END__

=head1 NAME

WTSI::DNAP::Utilities::ConfigureLogger

=head1 DESCRIPTION

Configure logging with log4perl. Includes default log configuration settings.

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
