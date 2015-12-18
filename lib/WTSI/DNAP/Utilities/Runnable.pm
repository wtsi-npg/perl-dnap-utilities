
package WTSI::DNAP::Utilities::Runnable;

use strict;
use warnings;
use Encode qw(decode);
use English qw(-no_match_vars);
use IPC::Run;
use Moose;

our $VERSION = '';

with 'WTSI::DNAP::Utilities::Loggable', 'WTSI::DNAP::Utilities::Executable';

=head2 run

  Example    : WTSI::DNAP::Utilities::Runnable->new(executable => 'ls',
                                                    arguments  => ['/'])->run;

  Description: Run the executable with the supplied arguments and STDIN.
               STDIN, STDOUT and STDERR may be accessed via the methods of
               WTSI::DNAP::Utilities::Executable. Dies on non-zero exit of
               child. Returns $self.
  Returntype : WTSI::DNAP::Utilities::Runnable

=cut

sub run {
  my ($self) = @_;

  my @ipc_args = ([$self->executable, @{$self->arguments}],
                  q{<},  $self->stdin,
                  q{>},  $self->stdout,
                  q{2>}, $self->stderr);
  $self->_run(@ipc_args);

  return $self;
}

=head2 pipe

  Arg [n]    : Any number of other runnables to be piped togther,
               Array[WTSI::DNAP::Utilities::Runnable]
  Example    : my $view     = WTSI::DNAP::Utilities::Runnable->new
                 (executable => 'samtools',
                  arguments   => ['view', 'irods:15440_1#0.sam']);
               my $flagstat = WTSI::DNAP::Utilities::Runnable->new
                 (executable => 'samtools',
                  arguments  => ['flagstat', '-']);

               my @stats_records = $view->pipe($flagstat)->split_stdout;

  Description: Run the executables with the supplied arguments and STDIN.
               STDOUT is piped to STDIN of the first argument, STDOUT of
               the first argument is piped to STDIN of the second etc.
               STDIN, STDOUT and STDERR may be accessed via the methods of
               WTSI::DNAP::Utilities::Executable. Dies on non-zero exit of
               child. Returns $self.
  Returntype : WTSI::DNAP::Utilities::Runnable

=cut

## no critic (Subroutines::ProhibitBuiltinHomonyms)
sub pipe {
  my ($self, @runnables) = @_;

  my @ipc_args = ([$self->executable, @{$self->arguments}],
                  q{<}, $self->stdin);

  foreach my $runnable (@runnables) {
    push @ipc_args, q{|}, [$runnable->executable, @{$runnable->arguments}];
  }
  push @ipc_args, q{>},  $self->stdout,
                  q{2>}, $self->stderr;

  $self->_run(@ipc_args);

  return $self;
}
## use critic

=head2 split_stdout

  Example    : WTSI::DNAP::Utilities::Runnable->new
                   (executable => 'ls',
                    arguments  => ['/'])->run->split_stdout

  Description: If $self->stdout is a ScalarRef, dereference and split on the
               supplied delimiter (defaults to the input record separator).
               Raises an error if $self->stdout is not a ScalarRef.
  Returntype : Array[Str]

=cut

sub split_stdout {
  my ($self) = @_;

  ref $self->stdout eq 'SCALAR' or
    $self->logconfess('The stdout attribute was not a scalar reference');

  my $copy = decode('UTF-8', ${$self->stdout}, Encode::FB_CROAK);

  return split $INPUT_RECORD_SEPARATOR, $copy;
}

=head2 split_stderr

  Example    : WTSI::DNAP::Utilities::Runnable->new
                  (executable => 'ls',
                   arguments  => ['/'])->run->split_stderr

  Description: If $self->stderr is a ScalarRef, dereference and split on the
               supplied delimiter (defaults to the input record separator).
               Raises an error if $self->stderr is not a ScalarRef.
  Returntype : Array[Str]

=cut

sub split_stderr {
  my ($self) = @_;

  ref $self->stderr eq 'SCALAR' or
    $self->logconfess('The stderr attribute was not a scalar reference');

  my $copy = decode('UTF-8', ${$self->stderr}, Encode::FB_CROAK);

  return split $INPUT_RECORD_SEPARATOR, $copy;
}

sub _run {
  my ($self, @ipc_args) = @_;

  my $command = join q{ }, map { ref $_ eq 'ARRAY' ? @{$_} : $_ } @ipc_args;
  $self->debug("Running '$command'");

  my $success;
  {
    local %ENV = %{$self->environment};
    $success = IPC::Run::run(@ipc_args);
  }

  if ($success) {
    $self->debug("Execution of '$command' succeeded");
  }
  else {
    my $status = $CHILD_ERROR;
    if ($status) {
      ##no critic (ValuesAndExpressions::ProhibitMagicNumbers)
      my $signal = $status & 127;
      my $exit   = $status >> 8;
      ##use critic

      if ($signal) {
        $self->logconfess("Execution of '$command' died from signal: $signal");
      }
      else {
        $self->logconfess("Execution of '$command' failed with exit code: ",
                          "$exit and STDERR ",
                          q{'}, join(q{ }, $self->split_stderr), q{'});
      }
    }
  }

  return $success;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=head1 NAME

WTSI::DNAP::Utilities::Runnable

=head1 DESCRIPTION

An instance of this class enables an external program to be run (using
IPC::Run::run).

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (C) 2013, 2014 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
