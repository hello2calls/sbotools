package SBO::App::Remove;

# vim: ts=2:et
#
# authors: Luke Williams <xocel@iquidus.org>
#          Jacob Pipkin <j@dawnrazor.net>
#          Andreas Guldstrand <andreas.guldstrand@gmail.com>
# license: WTFPL <http://sam.zoy.org/wtfpl/COPYING>

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use File::Basename;

sub new {
  my $class = shift;

  my $self = _parse_opts(@_);
  $self->{fname} = basename( (caller(0))[1] );

  return bless $self, $class;
}

1;
