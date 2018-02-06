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
use Fcntl                       qw/:mode/;
use File::Spec;
use POSIX                       qw/modf/;
use Errno                       qw/EEXIST/;
use List::MoreUtils             qw/natatime/;
use Try::Catch;
use Carp;
use Data::Dumper;

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

    return $self->stat(path => $args{path}) ? 1 : 0;
}

sub getatime
{
    my $self = shift;
    my %args = @_;

    return $self->stat(path => $args{path})->st_atime;
}

sub getctime
{
    my $self = shift;
    my %args = @_;

    return $self->stat(path => $args{path})->st_atime;
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

    return $self->stat(path => $args{path})->st_mtime;
}

sub getsize
{
    my $self = shift;
    my %args = @_;

    return $self->stat(path => $args{path})->st_size;
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

    return S_ISDIR($self->stat(path => $args{path})->st_mode);
}

sub isfile
{
    my $self = shift;
    my %args = @_;

    return S_ISREG($self->stat(path => $args{path})->st_mode);
}

sub islink
{
    my $self = shift;
    my %args = @_;

    return S_ISLNK($self->stat(path => $args{path})->st_mode);
}

sub listdir
{
    my $self = shift;
    my %args = @_;

    my @dirs;

    foreach my $entry ($self->opendir(path => $args{path}))
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

    my $iter = natatime(2, $self->opendir(path => $args{path}, readdirplus => 1));

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

    my $iter = nattime(2, $self->opendir(path => $args{path}), readdirplus => 1);

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
        my $rc = $self->makedirs(path => $head, mode => $args{mode});

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

    $self->mkdir(path => $args{path}, mode => $args{mode});

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

    # :TODO
    # mode 유효성 검사 및 변환
    my $flags = $args{mode};

    my $fd;

    if ((O_CREAT & $flags) == O_CREAT)
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

    # :TODO 2017년 05월 19일 11시 02분 12초: mode 유효성 검사 및 변환

    my $fd;

    if ((O_CREAT & $args{flags}) == O_CREAT)
    {
        $fd = glfs_creat($self->fs, $args{path}, $args{flags}, $args{mode});

        if (!defined($fd))
        {
            confess(sprintf('glfs_creat(%s, %s, %o, 0666) failed: %s'
                    , $self->fs, $args{path}, $flags, $!));
        }
    }
    else
    {
        $fd = glfs_open($self->fs, $args{path}, $args{flags});

        if (!defined($fd))
        {
            confess(sprintf('glfs_open(%s, %s, %o) failed: %s'
                    , $self->fs, $args{path}, $flags, $!));
        }
    }

    return $fd;
}

sub opendir
{
    my $self = shift;
    my %args = @_;

    $args{readdirplus} = 0;

    my $fd = glfs_opendir($self->fs, $args{path});

    if (!defined($fd))
    {
        confess(sprintf('glfs_opendir(%s, %s) failed: %s'
                , $self->fs, $args{path}));
    }

    return GlusterFS::GFAPI::FFI::Dir->new(fd => $fd, readdirplus => $args{readdirplus});
}

sub readlink
{
    my $self = shift;
    my %args = @_;

    my $buf = "\0" x PATH_MAX;
    my $ret = glfs_readlink($self->fs, $args{path}, $buf, PATH_MAX);

    if ($ret < 0)
    {
        confess(sprintf('glfs_readlink(%s, %s, %s, %d) failed: %s'
                , $self->fs, $args{path}, 'buf', PATH_MAX, $!));
    }

    return substr($buf, 0, $ret);
}

sub remove
{
    my $self = shift;
    my %args = @_;

    return $self->unlink(path => $args{path});
}

sub removexattr
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_removexattr($self->fs, $args{path}, $args{key});

    if ($ret < 0)
    {
        confess(sprintf('glfs_removexattr(%s, %s, %s) failed: %s'
                , $self->fs, $args{path}, $args{key}, $!));
    }

    return 0;
}

sub rename
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_rename($self->fs, $args{src}, $args{dst});

    if ($ret < 0)
    {
        confess(sprintf('glfs_rename(%s, %s, %s) failed: %s'
                , $self->fs, $args{src}, $args{dst}, $!));
    }

    return 0;
}

sub rmdir
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_rmdir($self->fs, $args{path});

    if ($ret < 0)
    {
        confess(sprintf('glfs_rmdir(%s, %s) failed: %s'
                , $self->fs, $args{path}, $!));
    }

    return 0;
}

sub rmtree
{
    my $self = shift;
    my %args = @_;

    $args{ignore_errors} = 0;
    $args{onerror}       = undef;

    if ($self->islink(path => $args{path}))
    {
        confess('Cannot call rmtree on a symbolic link');
    }

    try
    {
        foreach my $entry ($self->scandir(path => $args{path}))
        {
            my $fullname = join('/', $args{path}, $entry->name);

            if ($entry->is_dir(follow_symlinks => 0))
            {
                $self->rmtree(
                    path          => $fullname,
                    ignore_errors => $args{ignore_errors},
                    onerror       => $args{onerror});
            }
            else
            {
                try
                {
                    $self->unlink(path => $fullname);
                }
                catch
                {
                    my $e = shift;

                    $args{onerror}->($self, \&unlink, $fullname, $e)
                        if (ref($args{onerror}) eq 'CODE');
                };
            }
        }
    }
    catch
    {
        my $e = shift;

        $args{onerror}->($self, \&scandir, $args{path}, $e)
            if (ref($args{onerror}) eq 'CODE');
    };

    try
    {
        $self->rmdir(path => $args{path});
    }
    catch
    {
        my $e = shift;

        $args{onerror}->($self, \&rmdir, $args{path}, $e);
    };

    return 0;
}

sub setfsuid
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_setfsuid($args{uid});

    if ($ret < 0)
    {
        confess(sprintf('glfs_setfsuid(%d) failed: %s'
                , $args{uid}, $!));
    }

    return 0;
}

sub setfsgid
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_setfsgid($args{gid});

    if ($ret < 0)
    {
        confess(sprintf('glfs_setfsguid(%d) failed: %s'
                , $args{gid}, $!));
    }

    return 0;
}

sub setxattr
{
    my $self = shift;
    my %args = @_;

    $args{flags} = 0;

    my $ret = glfs_setxattr($self->fs, $args{path}, $args{key}
                            , $args{value}, length($args{value})
                            , $args{flags});

    if ($ret < 0)
    {
        confess(sprintf('glfs_setxattr(%s, %s, %s, %s, %d, %o) failed: %s'
                , $self->fs, $args{path}, $args{key}
                , $args{value}, length($args{value})
                , $args{flags}));
    }

    return 0;
}

sub stat
{
    my $self = shift;
    my %args = @_;

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();
    my $rc   = glfs_stat($self->fs, $args{path}, $stat);

    if ($rc < 0)
    {
        confess(sprintf('glfs_stat(%s, %s, %s) failed: %s'
                , $self->fs, $args{path}, 'buf', $stat));
    }

    return 0;
}

sub statvfs
{
    my $self = shift;
    my %args = @_;

    my $stat = GlusterFS::GFAPI::FFI::Statvfs->new();
    my $rc   = glfs_statvfs($self->fs, $args{path}, $stat);

    if ($rc < 0)
    {
        confess(sprintf('glfs_statvfs(%s, %s, %s) failed: %s'
                , $self->fs, $args{path}, 'buf', $stat));
    }

    return 0;
}

sub link
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_link($self->fs, $args{source}, $args{link_name});

    if ($ret < 0)
    {
        confess(sprintf('glfs_link(%s, %s, %s) failed: %s'
                , $self->fs, $args{source}, $args{link_name}, $!));
    }

    return 0;
}

sub symlink
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_symlink($self->fs, $args{source}, $args{link_name});

    if ($ret < 0)
    {
        confess(sprintf('glfs_symlink(%s, %s, %s) failed: %s'
                , $self->fs, $args{source}, $args{link_name}));
    }

    return 0;
}

sub unlink
{
    my $self = shift;
    my %args = @_;

    my $ret = glfs_unlink($self->fs, $args{path});

    if ($ret < 0)
    {
        confess(sprintf('glfs_unlink(%s, %s) failed: %s'
                , $self->fs, $args{path}, $!));
    }

    return 0;
}

sub utime
{
    my $self = shift;
    my %args = @_;

    my $now;

    $args{atime} = time() if (!defined($args{atime}));
    $args{mtime} = time() if (!defined($args{mtime}));

    my $tspecs = GlusterFS::GFAPI::FFI::Timespecs->new();

    # Set atime
    my ($fractional, $integral) = modf($args{atime});

    $tspecs->atime_sec(int($integral));
    $tspecs->atime_nsec(int($fractional * 1e9));

    # Set mtime
    ($fractional, $integral) = modf($args{mtime});

    $tspecs->mtime_sec(int($integral));
    $tspecs->mtime_nsec(int($fractional * 1e9));

    my $ret = glfs_utimens($self->fs, $args{path}, $tspecs);

    if ($ret < 0)
    {
        confess(sprintf('glfs_utimens(%s, %s, %s) failed: %s'
                , $self->fs, $args{path}, Dumper($tspecs), $!));
    }

    return 0;
}

sub walk
{
    my $self = shift;
    my %args = @_;

    if (!defined($args{topdown}))
    {
        $args{topdown} = 1;
    }

    if (!defined($args{onerror}))
    {
        $args{onerror} = undef;
    }

    if (!defined($args{followlinks}))
    {
        $args{followlinks} = 0;
    }

    my @dirs    = ();
    my @nondirs = ();

    try
    {
        foreach my $entry ($self->scandir(path => $args{top}))
        {
            if ($entry->is_dir(follow_symlinks => $args{followlinks}))
            {
                push(@dirs, $entry);
            }
            else
            {
                push(@nondirs, $entry->name);
            }
        }
    }
    catch
    {
        if (defined($args{onerror}))
        {
            $args{onerror}->(@_);
        }

        return;
    };

    if ($args{topdown})
    {
        # yield top, [d.name for d in dirs], nondirs
    }

    foreach my $directory (@dirs)
    {
        # NOTE: Both is_dir() and is_symlink() can be true for the same path
        # when follow_symlinks is set to True
        if ($args{followlinks} || ! $directory->is_symlink())
        {
            my $new_path = join($args{top}, $directory->name);

            foreach my $x ($self->walk(top         => $new_path,
                                       topdown     => $args{topdown},
                                       onerror     => $args{onerror},
                                       followlinks => $args{followlinks}))
            {
                # yield x
            }
        }
    }

    if (!$args{topdown})
    {
        # yield top, [d.name for d in dirs], nondirs
    }

    return 0;
}

sub samefile
{
    my $self = shift;
    my %args = @_;

    my $s1 = $self->stat(path => $args{path1});
    my $s2 = $self->stat(path => $args{path2});

    return $s1->st_ino == $s2->st_ino && $s1->st_dev == $s2->st_dev;
}

sub copyfileobj
{
    my $self = shift;
    my %args = @_;

    if (!defined($args{length}))
    {
        $args{length} = 128 * 1024;
    }

    my $buf = bytearray(length);

    while (1)
    {
        my $nread = $args{fsrc}->readinto($buf);

        if (!$nread || $nread <= 0)
        {
            break;
        }

        if ($nread == $length)
        {
            $args{fdst}->write($buf);
        }
        else
        {
            # TODO:
            # Use memoryview to avoid internal copy done on slicing.
            $args{fdst}->write(substr($buf, 0, $nread));
        }
    }

    return 0;
}

sub copyfile
{
    my $self = shift;
    my %args = @_;

    my $samefile = 0;

    try
    {
        $samefile = $self->samefile(path1 => $args{src}, path2 => $args{dst});
    }
    catch
    {
        return;
    };

    if ($samefile)
    {
        confess(sprintf('`%s` and `%s` are the same file', $args{src}, $args{dst}));
    }

    my $fsrc = $self->fopen(path => $args{src}, mode => 'rb');
    my $fdst = $self->fopen(path => $args{dst}, mode => 'wb');

    return $self->copyfileobj(fsrc => $fsrc, fdst => $fdst);
}

sub copymode
{
    my $self = shift;
    my %args = @_;

    my $st   = $self->stat(path => $args{src});
    my $mode = S_IMODE($st->st_mode);

    return $self->chmod(path => $args{dst}, mode => $mode);
}

sub copystat
{
    my $self = shift;
    my %args = @_;

    my $st   = $self->stat(path => $args{src});
    my $mode = S_IMODE($st->st_mode);

    my $ret = 0;

    $ret |= $self->utime(path => $args{dst},
                         atime => $st->st_atime,
                         mtime => $st->st_mtime);
    $ret |= $self->chmod(path => $args{dst}, mode => $mode);

    # TODO: Handle st_flags on FreeBSD
    return $ret;
}

sub copy
{
    my $self = shift;
    my %args = @_;

    if ($self->isdir(path => $args{dst}))
    {
        $args{dst} = join($args{dst}, basename($args{src}));
    }

    my $ret = 0;

    $ret |= $self->copyfile(src => $args{src}, dst => $args{dst});
    $ret |= $self->copymode(src => $args{src}, dst => $args{dst});

    return $ret;
}

sub copy2
{
    my $self = shift;
    my %args = @_;

    if ($self->isdir(path => $args{dst}))
    {
        $args{dst} = join($args{dst}, basename($args{src}));
    }

    my $ret = 0;

    $ret |= $self->copyfile($args{src}, $args{dst});
    $ret |= $self->copystat($args{src}, $args{dst});

    return $ret;
}

sub copytree
{
    my $self = shift;
    my %args = @_;

    if (!defined($args{symlinks}))
    {
        $args{symlinks} = 0;
    }

    if (!defined($args{ignore}))
    {
        $args{ignore} = undef;
    }

    my $names_with_stat = $self->listdir_with_stat(path => $args{src});

    my @ignored_names;

    if (defined($args{ignore}))
    {
        @ignored_names = ignore();
    }
    else
    {
        @ignored_names = set();
    }

    $self->makedirs(path => $args{dst});

    my @errors = ();

    my $iter = natatime(2, @{$names_with_stat});

    while (my ($name, $st) = $iter->())
    {
        if (grep { $name eq $_; } @ignored_names)
        {
            next;
        }

        my $srcpath = join($args{src}, $name);
        my $dstpath = join($args{dst}, $name);

        try
        {
            if ($args{symlinks} && S_ISLNK($st->st_mode))
            {
                my $linkto = $self->readlink($srcpath);
                $self->symlink($linkto, $dstpath);
            }
            elsif ($_isdir->($srcpath, $st, follow_symlinks => !$args{symlinks}))
            {
                $self->copytree(src => $srcpath, dst => $dstpath, symlinks => $args{symlinks});
            }
            else
            {
                my $fsrc = $self->fopen(path => $srcpath, 'rb');
                my $fdst = $self->fopen(path => $dstpath, 'wb');

                $self->copyfileobj(fsrc => $fsrc, fdst => $fdst);

                $self->utime(path => $dstpath, ($st->st_atime, $st->st_mtime));
                $self->chmod(path => $dstpath, S_IMODE($st->st_mode));
            }
        }
        catch
        {
            push(@errors, { src => $srcpath, dst => $dstpath, reason => \@_ });
        };
    }

    try
    {
        $self->copystat(src => $src, dst => $dst);
    }
    catch
    {
        push(@errors, { src => $src, dst => $dst, reason => \@_ });
    };

    return @errors;
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

This software is copyright 2017-2018 by Ji-Hyeon Gim.

This is free software; you can redistribute it and/or modify it under the same terms as the GPLv2/LGPLv3.

=cut

