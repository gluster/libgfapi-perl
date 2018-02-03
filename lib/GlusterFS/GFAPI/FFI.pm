package GlusterFS::GFAPI::FFI::Stat;

use FFI::Platypus::Record;

record_layout(qw/
    ulong   st_dev
    ulong   st_ino
    ulong   st_nlink
    uint    st_mode
    uint    st_uid
    uint    st_gid
    ulong   st_rdev
    ulong   st_size
    ulong   st_blksize
    ulong   st_blocks
    ulong   st_atime
    ulong   st_atimensec
    ulong   st_mtime
    ulong   st_mtimensec
    ulong   st_ctime
    ulong   st_ctimensec
/);

package GlusterFS::GFAPI::FFI::Statvfs;

use FFI::Platypus::Record;

record_layout(qw/
    ulong   f_bsize
    ulong   f_frsize
    ulong   f_blocks
    ulong   f_bfree
    ulong   f_bavail
    ulong   f_files
    ulong   f_ffree
    ulong   f_favail
    ulong   f_fsid
    ulong   f_flag
    ulong   f_namemax
    int[6]  __f_spare
/);

package GlusterFS::GFAPI::FFI::Dirent;

use FFI::Platypus::Record;

record_layout(qw/
    ulong       d_ino
    ulong       d_off
    ushort      d_reclen
    char        d_type
    string(256) d_name
/);

package GlusterFS::GFAPI::FFI::Timespecs;

use FFI::Platypus::Record;

record_layout(qw/
    long    atime_sec
    long    atime_nsec
    long    mtime_sec
    long    mtime_nsec
/);

package GlusterFS::GFAPI::FFI::Iovec;

use FFI::Platypus::Record;

record_layout(qw/
    opaque  iov_base
    size_t  iov_len
/);

#package GlusterFS::GFAPI::FFI::IovecArray;
#
#sub new
#{
#    my ($class, %args) = @_;
#
#    my $self = {
#        list => [],
#    };
#
#    bless $self, $class;
#
#    return $self;
#}
#
#sub list
#{
#    my $self = shift;
#    my %args = @_;
#
#    return @{$self->{list}};
#}
#
#sub count
#{
#    my $self = shift;
#    my %args = @_;
#
#    return scalar(@{$self->{list}});
#}
#
#sub add
#{
#    my $self = shift;
#    my $buff = shift;
#
#    my ($p_buff, $len) = buffer_from_scalar($buff);
#
#    my %vector = (
#        iov_base => $p_buff,
#        iov_len  => $len,
#    );
#
#    return push(@{$self->{list}}, \%vector);
#}
#
#sub del
#{
#    my $self = shift;
#    my $idx  = shift;
#
#    my $vector;
#
#    if (defined($idx) && $idx < $self->count)
#    {
#        $vector = splice(@{$self->{list}}, $idx, 1);
#    }
#
#    return try
#    {
#        if ($vector->{iov_base})
#        {
#            free($vector->{iov_base});
#        }
#
#        return 0;
#    }
#    catch
#    {
#        return -1;
#    };
#}

package GlusterFS::GFAPI::FFI::Flock;

use FFI::Platypus::Record;

record_layout(qw/
    short   l_type
    short   l_whence
    off_t   l_start
    off_t   l_len
    sint32  l_pid
/);

# /* Type of lock: F_RDLCK, F_WRLCK, F_UNLCK */
# /* How to interpret l_start: SEEK_SET, SEEK_CUR, SEEK_END */
# /* Starting offset for lock */
# /* Number of bytes to lock */
# /* PID of process blocking our lock (set by F_GETLK and F_OFD_GETLK) */

package GlusterFS::GFAPI::FFI;

BEGIN
{
    our $AUTHOR  = 'cpan:potatogim';
    our $VERSION = '0.01';
}

use strict;
use warnings;
use utf8;

use FFI::Platypus;
use FFI::Platypus::API;
use FFI::Platypus::Declare  qw/void string opaque/;
use FFI::Platypus::Memory   qw/calloc free memcpy/;
use FFI::Platypus::Buffer   qw/scalar_to_buffer/;

use GlusterFS::GFAPI::FFI::Util qw/libgfapi_soname/;
use Carp;
use Data::Dumper;

our $FFI = FFI::Platypus->new(lib => libgfapi_soname());

sub new
{
    # Custom type
    $FFI->type('int'        => 'ssize_t');
    $FFI->type('record(16)' => 'uuid_t');
    $FFI->type('opaque'     => 'glfs_t');
    $FFI->type('opaque'     => 'glfs_fd_t');
    $FFI->type('opaque'     => 'glfs_object');

    $FFI->type('record(GlusterFS::GFAPI::FFI::Stat)'      => 'Stat');
    $FFI->type('record(GlusterFS::GFAPI::FFI::Statvfs)'   => 'Statvfs');
    $FFI->type('record(GlusterFS::GFAPI::FFI::Dirent)'    => 'Dirent');
    $FFI->type('record(GlusterFS::GFAPI::FFI::Timespecs)' => 'Timespecs');
    $FFI->type('record(GlusterFS::GFAPI::FFI::Iovec)'     => 'Iovec');
    $FFI->type('record(GlusterFS::GFAPI::FFI::Flock)'     => 'Flock');

    # Closure
    $FFI->type('(glfs_fd_t, ssize_t, opaque)->opaque', 'glfs_io_cbk');

    # Type-Caster
    $FFI->attach_cast('cast_Dirent', 'opaque', 'Dirent');

    # Facilities
    $FFI->attach(glfs_init => ['glfs_t'], => 'int');
    $FFI->attach(glfs_new => ['string'] => 'glfs_t');
    $FFI->attach(glfs_set_volfile_server => ['glfs_t', 'string', 'string', 'int'] => 'int');
    $FFI->attach(glfs_set_logging => ['glfs_t', 'string', 'int'] => 'int');
    $FFI->attach(glfs_fini => ['glfs_t'] => 'int');

    # Features
    $FFI->attach(glfs_get_volumeid => ['glfs_t', 'uuid_t', 'size_t'] => 'int');
    $FFI->attach(glfs_setfsuid => ['unsigned int'] => 'int');
    $FFI->attach(glfs_setfsgid => ['unsigned int'] => 'int');
    $FFI->attach(glfs_setfsgroups => ['size_t', 'int*'] => 'int');
    $FFI->attach(glfs_open => ['glfs_t', 'string', 'int'] => 'glfs_fd_t');
    $FFI->attach(glfs_creat => ['glfs_t', 'string', 'int', 'mode_t'] => 'glfs_fd_t');
    $FFI->attach(glfs_close => ['glfs_fd_t'] => 'int');
    $FFI->attach(glfs_from_glfd => ['glfs_fd_t'] => 'glfs_t');
    $FFI->attach(glfs_set_xlator_option => ['glfs_t', 'string', 'string', 'string'] => 'int');
    $FFI->attach(glfs_read => ['glfs_fd_t', 'opaque', 'size_t', 'int'] => 'ssize_t');
    $FFI->attach(glfs_write => ['glfs_fd_t', 'opaque', 'size_t', 'int'] => 'ssize_t');
    $FFI->attach(glfs_read_async => ['glfs_fd_t', 'opaque', 'size_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_write_async => ['glfs_fd_t', 'opaque', 'size_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');

    $FFI->attach(glfs_readv => ['glfs_fd_t', 'opaque', 'int', 'int'] => 'ssize_t'
        , sub {
            my ($sub, $fd, $lengths, $flags) = @_;

            my $vsize = $FFI->sizeof('Iovec');
            my $psize = $FFI->sizeof('opaque');
            my $count = scalar(@{$lengths});

            # 버퍼 할당
            my @data   = ();
            my $buffer = calloc($count, $vsize);
            my @ptrs   = ();

            for (my $i=0; $i<$count; $i++)
            {
                $data[$i]      = "\0" x $lengths->[$i];
                $lengths->[$i] = pack('L!', $lengths->[$i]);

                my $p_base  = pack('P', $data[$i]);
                my $p_len   = pack('P', $lengths->[$i]);
                my $pp_base = pack('P', $p_base);

                push(@ptrs, $p_base, $p_len, $pp_base);

                memcpy($buffer + ($i * $vsize), unpack('L!', $pp_base), $psize);
                memcpy($buffer + ($i * $vsize) + $psize, unpack('L!', $p_len), $psize);
            }

            # readv 호출
            my $retval = $sub->($fd, $buffer, $count, $flags);

            free($buffer);

            return $retval, @data;
        });
    $FFI->attach(glfs_writev => ['glfs_fd_t', 'opaque', 'int', 'int'] => 'ssize_t'
        , sub {
            my ($sub, $fd, $vectors, $flags) = @_;

            my $vsize = $FFI->sizeof('Iovec');
            my $psize = $FFI->sizeof('opaque');
            my $count = scalar(@{$vectors});

            my $buffer = calloc($count, $vsize);

            for (my $i=0; $i<$count; $i++)
            {
                my ($buf_len, $sz_len) = scalar_to_buffer(pack('L!', length($vectors->[$i])));

                my $ptr  = pack('P', $vectors->[$i]);
                my $pptr = pack('P', $ptr);

                memcpy($buffer + ($vsize * $i), unpack('L!', $pptr), $psize);
                memcpy($buffer + ($vsize * $i) + $psize, $buf_len, $sz_len);
            }

            my $retval = $sub->($fd, $buffer, $count, $flags);

            free($buffer);

            return $retval;
        });
    $FFI->attach(glfs_readv_async => ['glfs_fd_t', 'Iovec', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_writev_async => ['glfs_fd_t', 'Iovec', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'int');

    $FFI->attach(glfs_pread => ['glfs_fd_t', 'opaque', 'size_t', 'int', 'int'] => 'ssize_t');
    $FFI->attach(glfs_pwrite => ['glfs_fd_t', 'opaque', 'size_t', 'int', 'int'] => 'ssize_t');
    $FFI->attach(glfs_pread_async => ['glfs_fd_t', 'opaque', 'size_t', 'off_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_pwrite_async => ['glfs_fd_t', 'opaque', 'size_t', 'off_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');

    $FFI->attach(glfs_preadv => ['glfs_fd_t', 'Iovec', 'size_t', 'int'] => 'int');
    $FFI->attach(glfs_pwritev => ['glfs_fd_t', 'Iovec', 'size_t', 'int'] => 'int');
    $FFI->attach(glfs_preadv_async => ['glfs_fd_t', 'Iovec', 'int', 'int', 'int', 'off_t', 'glfs_io_cbk', 'opaque'] => 'ssize_t');
    $FFI->attach(glfs_pwritev_async => ['glfs_fd_t', 'Iovec', 'int', 'int', 'int', 'off_t', 'glfs_io_cbk', 'opaque'] => 'ssize_t');

    $FFI->attach(glfs_lseek => ['glfs_fd_t', 'off_t', 'int'] => 'int');
    $FFI->attach(glfs_truncate => ['glfs_t', 'string', 'off_t'] => 'int');
    $FFI->attach(glfs_ftruncate => ['glfs_fd_t', 'off_t'] => 'int');
    $FFI->attach(glfs_ftruncate_async => ['glfs_fd_t', 'off_t', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_lstat => ['glfs_t', 'string', 'Stat'] => 'int');
    $FFI->attach(glfs_stat  => ['glfs_t', 'string', 'Stat'] => 'int');
    $FFI->attach(glfs_fstat => ['glfs_fd_t', 'Stat'] => 'int');
    $FFI->attach(glfs_fsync => ['glfs_fd_t'] => 'int');
    $FFI->attach(glfs_fsync_async => ['glfs_fd_t', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_fdatasync => ['glfs_fd_t'] => 'int');
    $FFI->attach(glfs_fdatasync_async => ['glfs_fd_t', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_access => ['glfs_t', 'string', 'int'] => 'int');
    $FFI->attach(glfs_symlink => ['glfs_t', 'string', 'string'] => 'int');
    $FFI->attach(glfs_readlink => ['glfs_t', 'string', 'string', 'size_t'] => 'int');
    $FFI->attach(glfs_mknod => ['glfs_t', 'string', 'mode_t', 'dev_t'] => 'int');
    $FFI->attach(glfs_mkdir => ['glfs_t', 'string', 'unsigned short'] => 'int');
    $FFI->attach(glfs_unlink => ['glfs_t', 'string'] => 'int');
    $FFI->attach(glfs_rmdir => ['glfs_t', 'string'] => 'int');
    $FFI->attach(glfs_rename => ['glfs_t', 'string', 'string'] => 'int');
    $FFI->attach(glfs_link => ['glfs_t', 'string', 'string'] => 'int');
    $FFI->attach(glfs_opendir => ['glfs_t', 'string'] => 'glfs_fd_t');
    $FFI->attach(glfs_readdir_r => ['glfs_fd_t', 'Dirent', 'opaque*'] => 'int');
    $FFI->attach(glfs_readdirplus_r => ['glfs_fd_t', 'Stat', 'Dirent', 'opaque*'] => 'int');
    $FFI->attach(glfs_readdir => ['glfs_fd_t'] => 'Dirent');
    $FFI->attach(glfs_readdirplus => ['glfs_fd_t', 'Stat'] => 'Dirent');
    $FFI->attach(glfs_telldir => ['glfs_fd_t'] => 'long');
    $FFI->attach(glfs_seekdir => ['glfs_fd_t', 'long'] => 'long');
    $FFI->attach(glfs_closedir => ['glfs_fd_t'] => 'int');
    $FFI->attach(glfs_statvfs => ['glfs_t', 'string', 'Statvfs'], => 'int');
    $FFI->attach(glfs_chmod => ['glfs_t', 'string', 'unsigned short'] => 'int');
    $FFI->attach(glfs_fchmod => ['glfs_fd_t', 'unsigned short'] => 'int');
    $FFI->attach(glfs_chown => ['glfs_t', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $FFI->attach(glfs_lchown => ['glfs_t', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $FFI->attach(glfs_fchown => ['glfs_fd_t', 'unsigned int', 'unsigned int'] => 'int');
    $FFI->attach(glfs_utimens => ['glfs_t', 'string', 'Timespecs'] => 'int');
    $FFI->attach(glfs_lutimens => ['glfs_t', 'string', 'Timespecs'] => 'int');
    $FFI->attach(glfs_futimens => ['glfs_fd_t', 'Timespecs'] => 'int');
    $FFI->attach(glfs_getxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_lgetxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_fgetxattr => ['glfs_fd_t', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_listxattr => ['glfs_t', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_llistxattr => ['glfs_t', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_flistxattr => ['glfs_fd_t', 'opaque', 'size_t'] => 'ssize_t');
    $FFI->attach(glfs_setxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $FFI->attach(glfs_lsetxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $FFI->attach(glfs_fsetxattr => ['glfs_fd_t', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $FFI->attach(glfs_removexattr => ['glfs_t', 'string', 'string'] => 'int');
    $FFI->attach(glfs_lremovexattr => ['glfs_t', 'string', 'string'] => 'int');
    $FFI->attach(glfs_fremovexattr => ['glfs_fd_t', 'string'] => 'int');
    $FFI->attach(glfs_fallocate => ['glfs_fd_t', 'int', 'off_t', 'size_t'] => 'int');
    $FFI->attach(glfs_discard => ['glfs_fd_t', 'off_t', 'size_t'] => 'int');
    $FFI->attach(glfs_discard_async => ['glfs_fd_t', 'off_t', 'size_t', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_zerofill => ['glfs_fd_t', 'off_t', 'size_t'] => 'int');
    $FFI->attach(glfs_zerofill_async => ['glfs_fd_t', 'off_t', 'off_t', 'glfs_io_cbk', 'opaque'] => 'int');
    $FFI->attach(glfs_getcwd => ['glfs_t', 'string', 'size_t'] => 'string');
    $FFI->attach(glfs_chdir => ['glfs_t', 'string'] => 'int');
    $FFI->attach(glfs_fchdir => ['glfs_fd_t'] => 'int');
    $FFI->attach(glfs_realpath => ['glfs_t', 'string', 'string'] => 'string');
    $FFI->attach(glfs_posix_lock => ['glfs_fd_t', 'int', 'Flock'] => 'int');
    $FFI->attach(glfs_dup => ['glfs_fd_t'] => 'glfs_fd_t');

    my %attrs = ();

    bless(\%attrs, __PACKAGE__);
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI - FFI Perl binding for GlusterFS libgfapi

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

