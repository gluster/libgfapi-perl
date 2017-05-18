package GlusterFS::GFAPI::FFI::Dir;

BEGIN
{
    our $AUTHOR  = 'cpan:potatogim';
    our $VERSION = '0.01';
}

use strict;
use warnings;
use utf8;

use Moo;
use GlusterFS::GFAPI::FFI;
use GlusterFS::GFAPI::FFI::Util qw/libgfapi_soname/;
use Carp;


#---------------------------------------------------------------------------
#   Attributes
#---------------------------------------------------------------------------
has 'fd' =>
(
    is => 'rwp',
);

has 'readdirplus' =>
(
    is => 'rw',
);

has 'cursor' =>
(
    is => 'rwp',
);


#---------------------------------------------------------------------------
#   Methods
#---------------------------------------------------------------------------
sub BUILD
{
    my $self = shift;
    my $args = shift;

    $self->_set_cursor(GlusterFS::GFAPI::FFI::Dirent->new());
}

sub next
{
    my $self = shift;
    my %args = @_;

    my $entry = GlusterFS::GFAPI::FFI::Dirent->new(d_reclen => 256);
    my $stat;

    my $ret;

    if ($self->readdirplus)
    {
        $stat = GlusterFS::GFAPI::FFI::Stat->new();
        $ret  = glfs_readdirplus_r($self->fd, $stat, $entry, $self->cursor);
    }
    else
    {
        $ret = glfs_readdir_r($self->fd, $entry, $self->cursor);
    }

    if ($ret != 0)
    {
        confess($!);
    }

    if (!defined($self->cursor) || !defined($self->cursor->contents))
    {
        confess('StopIteration');
    }

    return $self->readdirplus ? ($entry, $stat) : $entry;
}

sub DEMOLISH
{
    my ($self, $is_global) = @_;

    if (glfs_closedir($self->fd))
    {
        confess($!);
    }
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI::Dir - GFAPI Directory Iterator API

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

Ji-Hyeon Gim E<lt>potatogim@gluesys.comE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Ji-Hyeon Gim.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

