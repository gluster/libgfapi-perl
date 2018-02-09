package GlusterFS::GFAPI::FFI::DirEntry;

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
has 'name' =>
(
    is => 'rwp',
);

has 'vol' =>
(
    is => 'rwp',
);

has 'lstat' =>
(
    is => 'rwp',
);

has 'stat' =>
(
    is => 'rwp',
);

has 'path' =>
(
    is => 'rwp',
);


#---------------------------------------------------------------------------
#   Constructor/Destructor
#---------------------------------------------------------------------------
sub BUILD
{
    my $self = shift;
    my $args = shift;

    $self->_set_name($args->{name});
    $self->_set_vol($args->{vol});
    $self->_set_lstat($args->{lstat});
    $self->_set_stat(undef);
    $self->_set_path(join('/', $args->{name}));
}


#---------------------------------------------------------------------------
#   Methods
#---------------------------------------------------------------------------
sub stat
{
    my $self = shift;
    my %args = @_;

    if ($args{follow_symlinks})
    {
        if (!defined($self->stat))
        {
            if ($self->is_symlink)
            {
                $self->_set_stat($self->vol->stat($self->path));
            }
            else
            {
                $self->_set_stat($self->lstat);
            }
        }

        return $self->stat;
    }

    return $self->lstat;
}

sub is_dir
{
    my $self = shift;
    my %args = @_;

    if ($args{follow_symlinks} && $self->is_symlink())
    {
        return S_ISDIR($self->stat(follow_symlinks => 1)->st_mode);
    }

    return S_ISDIR($self->lstat->st_mode);
}

sub is_file
{
    my $self = shift;
    my %args = @_;

    if ($args{follow_symlinks} && $self->is_symlink())
    {
        return S_ISREG($self->stat(follow_symlinks => 1)->st_mode);
    }

    return S_ISREG($self->lstat->st_mode);
}

sub is_symlink
{
    my $self = shift;
    my %args = @_;

    return S_ISLNK($self->lstat->st_mode);
}

sub inode
{
    my $self = shift;
    my %args = @_;

    return $self->lstat->st_ino;
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI::DirEntry - GFAPI Directory Entry API

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

Ji-Hyeon Gim E<lt>potatogim@gluesys.comE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright 2017-2018 by Ji-Hyeon Gim.

This is free software; you can redistribute it and/or modify it under the same terms as the GPLv2/LGPLv3.

=cut

