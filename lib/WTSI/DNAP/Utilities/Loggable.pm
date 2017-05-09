package WTSI::DNAP::Utilities::Loggable;

use strict;
use warnings;
use Log::Log4perl;
use MooseX::Role::Parameterized;
use List::MoreUtils qw(any);
use Class::Load qw(load_class);

our $VERSION = '';

# This is used if Log:Log4perl has not been initialised elsewhere when
# this Role is used.
my $default_conf = << 'EOF';
log4perl.logger = WARN, A1

log4perl.appender.A1           = Log::Log4perl::Appender::Screen
log4perl.appender.A1.utf8      = 1
log4perl.appender.A1.layout    = Log::Log4perl::Layout::PatternLayout
log4perl.appender.A1.layout.ConversionPattern = %d %p %m %n
log4perl.appender.A1.utf8      = 1
EOF

# These methods are autodelegated to instances with this role.
our @HANDLED_LOG_METHODS = qw(trace debug info warn error fatal
                              logwarn logdie
                              logcarp logcluck logconfess logcroak);

parameter 'stderr2log' => (isa      => 'Bool',
                           required => 0,
                           is       => 'ro',);

role {
  my $stderr2log = shift;

  has 'logger' => (is      => 'rw',
                   isa     => 'Log::Log4perl::Logger',
                   handles => [@HANDLED_LOG_METHODS],
                   lazy    => 1,
                   builder => '_build_logger');

  method _build_logger => sub {
    my $self = shift;

    my $class_name = $self->meta->name;
    my $logger;

    if (not Log::Log4perl->initialized) {
      Log::Log4perl->init_once(\$default_conf);
      $logger = Log::Log4perl->get_logger($class_name);
      $logger->debug('Log4perl was initialised with default fallback ',
                   "configuration by the logger builder of '$class_name'");
    } else {
      $logger = Log::Log4perl->get_logger($class_name);

      # STDERR is redirected to a log at warn level. If this level is
      # not available, do not redirect.
      if ($logger->isWarnEnabled() && $stderr2log) {
        my $appenders = Log::Log4perl->appenders();
        # Check whether any of the existing appenders outout to STDERR.
        my $has_stderr_output = any { $_ }
                                map {$appenders->{$_}->{'appender'}->{'stderr'}}
                                keys %{$appenders};
        if (!$has_stderr_output) {
          load_class 'WTSI::DNAP::Utilities::Loggable::Redirected';
          tie *STDERR, 'WTSI::DNAP::Utilities::Loggable::Redirected';
        }
      }   
    }

    return $logger;
  };

};

no Moose;

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Loggable

=head1 DESCRIPTION

Provides a logging facility via Log::Log4perl. When consumed, this
role automatically delegates Log::Log4perl logging method calls to a
logger. If no logger is configured a default will be created where the
root logger is configured to WARN to STDERR.

The default logger returned by the 'logger' method is named after the
fully qualified name of the Moose meta class e.g.

 WTSI::NPG::iRODS

has a default logger addressable by the string

 log4perl.logger.WTSI.NPG.iRODS

This role accepts a boolean parameter stderr2log, which is false by
default.

  with 'WTSI::DNAP::Utilities::Loggable' => { stderr2log => 1 };

Enabling this parameter has an effect of redirecting standard error
stream to the log. Redirection is not activated if one of the existing
appenders already outputs to standard error or if the log level does not
support logging warnings.

Broader logging may be enabled by configuring a logger higher up the
class hierarchy e.g.

 log4perl.logger.WTSI.NPG

will configure loggers under the WTSI::NPG.iRODS hierarchy. As per the
log4perl documentation, different classes may be configured to log at
different levels and to different locations. Please see the Log4perl
FAQ if you observe logging that you do not expect e.g. duplicate
messages; there are tips in the FAQ on that topic.

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2013, 2014, 2016, 2017 Genome Research Limited. All Rights
Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
