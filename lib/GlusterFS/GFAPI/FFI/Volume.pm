package GlusterFS::GFAPI::FFI::Volume;

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
use File::Spec;
use Errno                       qw/EEXIST/;
use List::MoreUtils             qw/natatime/;
use Carp;

use constant
{
    PATH_MAX => 4096,
};


#---------------------------------------------------------------------------
#   Attributes
#---------------------------------------------------------------------------
has 'mounted' =>
(
    is => 'rwp',
);

has 'fs' =>
(
    is => 'rwp',
);

has 'log_file' =>
(
    is => 'rwp',
);

has 'log_level' =>
(
    is => 'rwp',
);

has 'host' =>
(
    is => 'rwp',
);

has 'volname' =>
(
    is => 'rwp',
);

has 'protocol' =>
(
    is => 'rwp',
);

has 'port' =>
(
    is => 'rwp',
);


#---------------------------------------------------------------------------
#   Lifecycle
#---------------------------------------------------------------------------
sub BUILD
{
    my $self = shift;
    my $args = shift;

    if (!defined($args->{volname}) || !defined($args->{host}))
    {
        confess('Host and Volume name should not be None.');
    }

    if ($args->{proto} !~ m/^(tcp|rdma)$/)
    {
        confess('Invalid protocol specified');
    }

    if ($args->{port} !~ m/^\d+$/)
    {
        confess('Invalid port specified.');
    }

    $self->_set_mounted(0);
    $self->_set_fs(undef);
    $self->_set_log_file($args->{log_file});
    $self->_set_log_level($args->{log_level});
    $self->_set_host($args->{host});
    $self->_set_volname($args->{volname});
    $self->_set_protocol($args->{proto});
    $self->_set_port($args->{port});
}

sub DEMOLISH
{
    my ($self, $is_global) = @_;

    $self->umount();
}


#---------------------------------------------------------------------------
#   Methods
#---------------------------------------------------------------------------
sub mount
{
    my $self = shift;
    my %args = @_;

    if ($self->fs && $self->mounted)
    {
        # Already mounted
        return 0;
    }

    $self->{fs} = glfs_new($self->volname);

    if (!defined($self->fs))
    {
        confess("glfs_new($self->volname) failed: $!");
    }

    my $ret = glfs_set_volfile_server($self->fs, $self->protocol, $self->host, $self->port);

    if ($ret < 0)
    {
        confess(sprintf('glfs_set_volfile_server(%s, %s, %s, %s) failed: %s'
                , $self->fs, $self->protocol, $self->host, $self->port, $!));
    }

    $self->set_logging($self->log_file, $self->log_level);

    if ($self->fs && !$self->mounted)
    {
        $ret = glfs_init($self->fs);

        if ($ret < 0)
        {
            confess("glfs_init($self->fs) failed: $!");
        }
        else
        {
            $self->_set_mounted(1);
        }
    }

    return $ret;
}

sub umount
{
    my $self = shift;
    my %args = @_;

    if ($self->fs)
    {
        if (glfs_fini($self->fs) < 0)
        {
            confess("glfs_fini($self->fs) failed: $!");
        }
        else
        {
            $self->_set_mounted(0);
            $self->_set_fs(undef);
        }
    }

    return 0;
}

sub set_logging
{
    my $self = shift;
    my %args = @_;

    my $ret;

    if ($self->fs)
    {
        $ret = glfs_set_logging($self->fs, $self->log_file, $self->log_level);

        if ($ret < 0)
        {
            confess("glfs_set_logging(%s, %s) failed: %s"
                , $self->log_file, $self->log_level, $!);
        }

        $self->_set_log_file($args{log_file});
        $self->_set_log_level($args{log_level});
    }

    return $ret;
}

sub access
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_success($self->fs, $args{path}, $args{mode});

    return $ret ? 0 : 1;
}

sub chdir
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_chdir($self->fs, $args{path});

    if ($ret < 0)
    {
        confess('glfs_chdir(%s, %s) failed: %s'
            , $self->fs, $args{path}, $!);
    }

    return $ret;
}

sub chmod
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_chmod($self->fs, $args{path}, $args{mode});

    if ($ret < 0)
    {
        confess('glfs_chmod(%s, %s, %d) failed: %s'
            , $self->fs, $args{path}, $args{mode}, $!);
    }

    return $ret;
}

sub chown
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_chown($self->fs, $args{path}, $args{uid}, $args{gid});

    if ($ret < 0)
    {
        confess('glfs_chown(%s, %s, %d, %d): failed: %s'
            , $self->fs, $args{path}, $args{uid}, $args{gid}, $!);
    }

    return $ret;
}

sub exists
{
    my $self = shift;
    my %args = @_;

    return $self->stat($args{path}) ? 1 : 0;
}

sub getatime
{
    my $self = shift;
    my %args = @_;

    return $self->stat($args{path})->st_atime;
}

sub getctime
{
    my $self = shift;
    my %args = @_;

    return $self->stat($args{path})->st_atime;
}

sub getcwd
{
    my $self = shift;
    my %args = @_;

    my $buf = "\0" x PATH_MAX;
    my $ret = glfs_getcwd($self->fs, $buf, PATH_MAX);

    if ($ret < 0)
    {
        confess('glfs_getcwd(%s) failed: %s', $self->fs, $!);
    }

    return $buf;
}

sub getmtime
{
    my $self = shift;
    my %args = @_;

    return $self->stat($args{path})->st_mtime;
}

sub getsize
{
    my $self = shift;
    my %args = @_;

    return $self->stat($args{path})->st_size;
}

sub getxattr
{
    my $self = shift;
    my %args = @_;

    if ($args{size} == 0)
    {
        $args{size} = glfs_getxattr($self->fs, $args{path}, $args{key}, undef, 0);

        if ($args{size} < 0)
        {
            confess('glfs_getxattr(%s, %s, %s) failed: %s'
                , $self->fs, $args{path}, $args{key}, $!);
        }
    }

    my $buf = "\0" x $args{size};
    my $rc  = glfs_getxattr($self->fs, $args{path}, $args{key}, $buf, $args{size});

    if ($rc < 0)
    {
        confess('glfs_getxattr(%s, %s, %s, %d) failed: %s'
            , $self->fs, $args{path}, $args{key}, $args{size});
    }

    return $buf;
}

sub isdir
{
    my $self = shift;
    my %args = @_;

    return S_ISDIR($self->stat($args{path})->st_mode);
}

sub isfile
{
    my $self = shift;
    my %args = @_;

    return S_ISREG($self->stat($args{path})->st_mode);
}

sub islink
{
    my $self = shift;
    my %args = @_;

    return S_ISLNK($self->stat($args{path})->st_mode);
}

sub listdir
{
    my $self = shift;
    my %args = @_;

    my @dirs;

    foreach my $entry ($self->opendir($args{path}))
    {
        if (ref($entry) ne 'GlusterFS::GFAPI::FFI::Dirent')
        {
            break;
        }

        my $name = substr($entry->d_name, 0, $entry->d_reclen);

        if ($name ne '.' && $name ne '..')
        {
            push(@dirs, $name);
        }
    }

    return \@dirs;
}

sub listdir_with_stat
{
    my $self = shift;
    my %args = @_;

    my @entries_with_stat;

    my $iter = natatime(2, $self->opendir($args{path}, readdirplus => 1));

    while (my ($entry, $stat) = $iter->())
    {
        if (ref($entry) ne 'GlusterFS::GFAPI::FFI::Dirent'
            || ref($stat) ne 'GlusterFS::GFAPI::FFI::Stat')
        {
            break;
        }

        my $name = substr($entry->d_name, 0, $entry->d_reclen);

        if ($name ne '.' && $name ne '..')
        {
            push(@entries_with_stat, $name, $stat);
        }
    }

    return \@entries_with_stat;
}

sub scandir
{
    my $self = shift;
    my %args = @_;

    my $iter = nattime(2, $self->opendir($args{path}), readdirplus => 1);

    while (my ($entry, $lstat) = $iter->())
    {
        my $name = substr($entry->d_name, 0, $entry->d_reclen);

        if ($name ne '.' && $name ne '..')
        {
            # TODO: equivalent for python yield
            # yield DirEntry($self, $args{path}, $name, $lstat);
        }
    }

    return 0;
}

sub listxattr
{
    my $self = shift;
    my %args = @_;

    if ($args{size} == 0)
    {
        $args{size} = glfs_listxattr($self->fs, $args{path}, undef, 0);

        if ($args{size} < 0)
        {
            confess(sprintf('glfs_listxattr(%s, %s, %d) failed: %s'
                    , $self->fs, $args{path}, 0, $!));
        }
    }

    my $buf = "\0" x $args{size};
    my $rc  = glfs_listxattr($self->fs, $args{path}, $buf, $args{size});

    if ($rc < 0)
    {
        confess(sprintf('glfs_listxattr(%s, %s, %d) failed: %s'
                , $self->fs, $args{path}, $args{size}, $!));
    }

    my @xattrs = ();

#    my $i = 0;
#
#    while ($i < $rc)
#    {
#        my $new_xa = $buf->raw;
#
#        $i++;
#
#        while ($i < $rc)
#        {
#            my $next_char = $buf->raw[$i];
#
#            $i++;
#
#            if ($next_char == "\0")
#            {
#                push(@xattrs, $new_xa)
#                break;
#            }
#
#            $new_xa += $next_char
#        }
#    }

    return sort(@xattrs);
}

sub lstat
{
    my $self = shift;
    my %args = @_;

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();
    my $rc   = glfs_lstat($self->fs, $args{path}, $stat);

    if ($rc < 0)
    {
        confess(sprintf('glfs_lstat(%s, %s) failed: %s'
                , $self->fs, $args{path}, $!));
    }

    return $stat;
}

sub makedirs
{
    my $self = shift;
    my %args = @_;

    $args{mode} //= 0777;

    my $head = substr($args{path}, 0, rindex($args{path}, '/'));
    my $tail = substr($args{path}, rindex($args{path}, '/'));

    if (!defined($tail))
    {
        $head = substr($head, 0, rindex($head, '/'));
        $tail = substr($head, rindex($head, '/'));
    }

    if (defined($head) && defined($tail) && !$self->exists($head))
    {
        my $rc = $self->makedirs($head, $args{mode});

        if ($! != EEXIST)
        {
            confess(sprintf('makedirs(%s, %o) failed: %s'
                    , $head, $args{mode}, $!));
        }

        if (!defined($tail) || $tail eq File::Spec->curdir())
        {
            return 0;
        }
    }

    $self->mkdir($args{path}, $args{mode});

    return 0;
}

sub mkdir
{
    my $self = shift;
    my %args = @_;

    $args{mode} //= 0777;

    my $ret = glfs_mkdir($self->fs, $args{path}, $args{mode});

    if ($ret < 0)
    {
        confess(sprintf('glfs_mkdir(%s, %s, %o) failed: %s'
                , $self->fs, $args{path}, $args{mode}, $!));
    }

    return 0;
}

sub fopen
{
    my $self = shift;
    my %args = @_;

    $args{mode} //= 'r';

    #:TODO mode 유효성 검사 및 변환
    my $flags = $args{mode};

    my $fd;

    if (O_CREAT & $flags == O_CREAT)
    {
        $fd = glfs_creat($self->fs, $args{path}, $flags, 0666);

        if (!defined($fd))
        {
            confess(sprintf('glfs_creat(%s, %s, %o, 0666) failed: %s'
                    , $self->fs, $args{path}, $flags, $!));
        }
    }
    else
    {
        $fd = glfs_open($self->fs, $args{path}, $flgas);

        if (!defined($fd))
        {
            confess(sprintf('glfs_open(%s, %s, %o) failed: %s'
                    , $self->fs, $args{path}, $flags, $!));
        }
    }

    return GlusterFS::GFAPI::FFI::File->new($fd, path => $args{path}, mode => $args{mode});
}

sub open
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub opendir
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub readlink
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub remove
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub removexattr
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub rename
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub rmdir
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub rmtree
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub setfsuid
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub setfsgid
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub setxattr
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub stat
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub statvfs
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub link
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub symlink
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub unlink
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub utime
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub walk
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub samefile
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copyfileobj
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copyfile
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copymode
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copystat
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copy
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copy2
{
    my $self = shift;
    my %args = @_;

    return 0;
}

sub copytree
{
    my $self = shift;
    my %args = @_;

    return 0;
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI::Volume - GFAPI Volume API

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

