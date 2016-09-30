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

our $CONFIG_KEY   = 'config';
our $LEVELS_KEY   = 'levels';
our $STDERR_KEY   = 'stderr';
our $STDOUT_KEY   = 'stdout';
our $FILE_KEY     = 'file';
our $CATEGORY_KEY = 'category';
our $LAYOUT_KEY   = 'layout';
our $UTF8_KEY     = 'utf8';
our @ALL_KEYS = ($CONFIG_KEY, $LEVELS_KEY, $STDERR_KEY, $STDOUT_KEY,
                 $FILE_KEY, $CATEGORY_KEY, $LAYOUT_KEY, $UTF8_KEY);

=head2 log_init

B<Arg [1]> :    [Hash] Arguments for log config

B<Example> :    log_init(%args);

B<Description:> Initializes logging with Log4perl.

Argument is a Hash. If any key/value pairs are omitted, default values will
be used. The following key/value pairs are allowed:

=over

=item *

I<config>:   String or StringRef. A log4perl config value. Either a string
with the path to a config file, or a string reference containing the
configuration. If defined, config will override all other arguments.

=item *

I<levels>:   ArrayRef. Contains zero or more Log4perl numeric level
identifiers. The log level will be the most verbose value in the ArrayRef,
or a default value if the ArrayRef is empty.

=item *

I<stderr>:   Boolean. If True, write log output to STDERR.
Default value is True.

=item *

I<stdout>:   Boolean. If True, write log output to STDOUT.
Default value is False.

=item *

I<file>:     String. If defined, write log output to the given path.

=item *

I<category>: String. If defined, use the given Log4perl category for
the logger.

=item *

I<layout>:   String. If defined, use the given layout format for logging;
otherwise, use a default layout.

=item *

I<utf8>:     Boolean. If True, use utf8 encoding for output.
Default value is True.

=back

B<Returntype> : True if initialization succeeded; croaks otherwise.

B<Caller>     : general

=cut

sub log_init {
    my %args = @_;

    # customised arguments
    my $config  = $args{$CONFIG_KEY};
    my $levels  = $args{$LEVELS_KEY};
    my $stderr  = $args{$STDERR_KEY};
    my $stdout  = $args{$STDOUT_KEY};
    my $file    = $args{$FILE_KEY};
    # arguments given directly to easy_init
    my $category = $args{$CATEGORY_KEY};
    my $layout   = $args{$LAYOUT_KEY} || '%d %p %m %n';
    my $utf8     = $args{$UTF8_KEY} || 1;

    # check for invalid hash keys
    my %all_keys;
    foreach my $key (@ALL_KEYS) { $all_keys{$key} = 1; }
    foreach my $key (keys %args) {
        if (! $all_keys{$key}) {
            carp("Invalid argument key '", $key, "' supplied to log_init; ",
                 "permitted keys are: (", (join ', ', @ALL_KEYS), ")");
        }
    }

    # configure and initialise logging
    if (defined $config) {
        Log::Log4perl::init($config);
    } else {
        my @log_args;
        my $common_args = {
            layout => $layout,
            level  => most_verbose($levels),
            utf8   => $utf8,
        };
        if (defined $category) { $common_args->{'category'} = $category; }
        if ($file) {
            my $args = { %$common_args }; # copies the $common_args hashref
            $args->{'file'} = ">>$file";
            push @log_args, $args;
        }
        if ($stderr || ! defined $stderr) { # write to STDERR by default
            my $args = { %$common_args }; # copies the $common_args hashref
            $args->{'file'} = "STDERR";
            push @log_args, $args;
        }
        if ($stdout) {
            my $args = { %$common_args }; # copies the $common_args hashref
            $args->{'file'} = "STDOUT";
            push @log_args, $args;
        }
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
