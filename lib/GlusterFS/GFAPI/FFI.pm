package GlusterFS::GFAPI::FFI::Stat;

use FFI::Platypus::Record;

# Stat
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

# Statvfs
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

package GlusterFS::GFAPI::FFI::Timespec;

use FFI::Platypus::Record;

# Timespec
record_layout(qw/
    long    tv_sec
    long    tv_nsec
/);

package GlusterFS::GFAPI::FFI::Dirent;

use FFI::Platypus::Record;

# Dirent
record_layout(qw/
    ulong       d_ino
    ulong       d_off
    ushort      d_reclen
    char        d_type
    string(256) d_name
/);

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
use FFI::Platypus::Memory   qw/malloc free/;
use FFI::Platypus::Buffer   qw/scalar_to_buffer buffer_to_scalar/;

use GlusterFS::GFAPI::FFI::Util qw/libgfapi_soname/;
use Carp;
use Data::Dumper;

sub new
{
    my $glfs_ffi = FFI::Platypus->new(lib => libgfapi_soname());

    # Custom type
    $glfs_ffi->type('int' => 'ssize_t');
    $glfs_ffi->type('record(16)' => 'uuid_t');
    $glfs_ffi->type('opaque' => 'glfs_t');
    $glfs_ffi->type('opaque' => 'glfs_fd_t');
    $glfs_ffi->type('opaque' => 'glfs_io_cbk');
    $glfs_ffi->type('opaque' => 'glfs_object');
    $glfs_ffi->type('record(GlusterFS::GFAPI::FFI::Stat)'     => 'Stat');
    $glfs_ffi->type('record(GlusterFS::GFAPI::FFI::Statvfs)'  => 'Statvfs');
    $glfs_ffi->type('record(GlusterFS::GFAPI::FFI::Dirent)'   => 'Dirent');
    $glfs_ffi->type('record(GlusterFS::GFAPI::FFI::Timespec)' => 'Timespec');

    # Type-Caster
    $glfs_ffi->attach_cast('cast_Dirent', 'opaque', 'Dirent');

    # Facilities
    $glfs_ffi->attach(glfs_init => ['glfs_t'], => 'int');
    $glfs_ffi->attach(glfs_new => ['string'] => 'glfs_t');
    $glfs_ffi->attach(glfs_set_volfile_server => ['glfs_t', 'string', 'string', 'int'] => 'int');
    $glfs_ffi->attach(glfs_set_logging => ['glfs_t', 'string', 'int'] => 'int');
    $glfs_ffi->attach(glfs_fini => ['glfs_t'] => 'int');

    # Features
    $glfs_ffi->attach(glfs_get_volumeid => ['glfs_t', 'uuid_t', 'size_t'] => 'int');
    $glfs_ffi->attach(glfs_setfsuid => ['unsigned int'] => 'int');
    $glfs_ffi->attach(glfs_setfsgid => ['unsigned int'] => 'int');
    $glfs_ffi->attach(glfs_setfsgroups => ['size_t', 'int*'] => 'int');
    $glfs_ffi->attach(glfs_open => ['glfs_t', 'string', 'int'] => 'glfs_fd_t');
    $glfs_ffi->attach(glfs_creat => ['glfs_t', 'string', 'int', 'mode_t'] => 'glfs_fd_t');
    $glfs_ffi->attach(glfs_close => ['glfs_fd_t'] => 'int');
    $glfs_ffi->attach(glfs_from_glfd => ['glfs_fd_t'] => 'glfs_t');
    $glfs_ffi->attach(glfs_set_xlator_option => ['glfs_t', 'string', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_read => ['opaque', 'opaque', 'size_t', 'int'] => 'ssize_t');
    $glfs_ffi->attach(glfs_write => ['opaque', 'opaque', 'size_t', 'int'] => 'ssize_t');
    #$glfs_ffi->attach(glfs_read_async => ['opaque', 'opaque', 'size_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    #$glfs_ffi->attach(glfs_write_async => ['opaque', 'opaque', 'size_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_readv => ['opaque', 'opaque', 'int', 'int'] => 'ssize_t');
    $glfs_ffi->attach(glfs_writev => ['opaque', 'opaque', 'int', 'int'] => 'ssize_t');
    #$glfs_ffi->attach(glfs_readv_async => ['opaque', 'opaque', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    #$glfs_ffi->attach(glfs_writev_async => ['opaque', 'opaque', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_pread => ['opaque', 'opaque', 'size_t', 'int', 'int'] => 'ssize_t');
    $glfs_ffi->attach(glfs_pwrite => ['opaque', 'opaque', 'size_t', 'int', 'int'] => 'ssize_t');
    #$glfs_ffi->attach(glfs_pread_async => ['opaque', 'opaque', 'size_t', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    #$glfs_ffi->attach(glfs_pwrite_async => ['opaque', 'opaque', 'size_t', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    #$glfs_ffi->attach(glfs_preadv => ['opaque', 'opaque', 'int', 'int', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'ssize_t');
    #$glfs_ffi->attach(glfs_pwritev => ['opaque', 'opaque', 'int', 'int', 'int', 'int', 'glfs_io_cbk', 'opaque'] => 'ssize_t');
    #$glfs_ffi->attach(glfs_preadv_async => ['opaque', 'opaque', 'size_t', 'int'] => 'int');
    #$glfs_ffi->attach(glfs_pwritev_async => ['opaque', 'opaque', 'size_t', 'int'] => 'int');
    $glfs_ffi->attach(glfs_lseek => ['opaque', 'int', 'int'] => 'int');
    $glfs_ffi->attach(glfs_truncate => ['glfs_t', 'string', 'int'] => 'int');
    $glfs_ffi->attach(glfs_ftruncate => ['opaque', 'int'] => 'int');
    #$glfs_ffi->attach(glfs_ftruncate_async => ['opaque', 'int', 'glfs_io_cbk', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_lstat => ['glfs_t', 'string', 'Stat'] => 'int');
    $glfs_ffi->attach(glfs_stat  => ['glfs_t', 'string', 'Stat'] => 'int');
    $glfs_ffi->attach(glfs_fstat => ['opaque', 'Stat'] => 'int');
    $glfs_ffi->attach(glfs_fsync => ['opaque'] => 'int');
    #$glfs_ffi->attach(glfs_fsync_async => ['opaque', 'glfs_io_cbk', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_fdatasync => ['opaque'] => 'int');
    #$glfs_ffi->attach(glfs_fdatasync_async => ['opaque', 'glfs_io_cbk', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_access => ['glfs_t', 'string', 'int'] => 'int');
    $glfs_ffi->attach(glfs_symlink => ['glfs_t', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_readlink => ['glfs_t', 'string', 'string', 'size_t'] => 'int');
    #$glfs_ffi->attach(glfs_mknod => ['glfs_t', 'string', 'mode_t', 'dev_t'] => 'int');
    $glfs_ffi->attach(glfs_mkdir => ['glfs_t', 'string', 'unsigned short'] => 'int');
    $glfs_ffi->attach(glfs_unlink => ['glfs_t', 'string'] => 'int');
    $glfs_ffi->attach(glfs_rmdir => ['glfs_t', 'string'] => 'int');
    $glfs_ffi->attach(glfs_rename => ['glfs_t', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_link => ['glfs_t', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_opendir => ['glfs_t', 'string'] => 'opaque');
    $glfs_ffi->attach(glfs_readdir_r => ['opaque', 'Dirent', 'opaque*'] => 'int');
    $glfs_ffi->attach(glfs_readdirplus_r => ['opaque', 'Stat', 'Dirent', 'opaque*'] => 'int');
    $glfs_ffi->attach(glfs_readdir => ['opaque'] => 'Dirent');
    $glfs_ffi->attach(glfs_readdirplus => ['opaque', 'Stat'] => 'Dirent');
    $glfs_ffi->attach(glfs_telldir => ['opaque'] => 'long');
    $glfs_ffi->attach(glfs_seekdir => ['opaque', 'long'] => 'long');
    $glfs_ffi->attach(glfs_closedir => ['opaque'] => 'int');
    $glfs_ffi->attach(glfs_statvfs => ['glfs_t', 'string', 'Statvfs'], => 'int');
    $glfs_ffi->attach(glfs_chmod => ['glfs_t', 'string', 'unsigned short'] => 'int');
    $glfs_ffi->attach(glfs_fchmod => ['opaque', 'unsigned short'] => 'int');
    $glfs_ffi->attach(glfs_chown => ['glfs_t', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $glfs_ffi->attach(glfs_lchown => ['glfs_t', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $glfs_ffi->attach(glfs_fchown => ['opaque', 'unsigned int', 'unsigned int'] => 'int');
    $glfs_ffi->attach(glfs_utimens => ['glfs_t', 'string', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_lutimens => ['glfs_t', 'string', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_futimens => ['opaque', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_getxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_lgetxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_fgetxattr => ['opaque', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_listxattr => ['opaque', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_llistxattr => ['glfs_t', 'string', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_flistxattr => ['glfs_t', 'opaque', 'size_t'] => 'ssize_t');
    $glfs_ffi->attach(glfs_setxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $glfs_ffi->attach(glfs_lsetxattr => ['glfs_t', 'string', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $glfs_ffi->attach(glfs_fsetxattr => ['opaque', 'string', 'opaque', 'size_t', 'int'] => 'int');
    $glfs_ffi->attach(glfs_removexattr => ['glfs_t', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_lremovexattr => ['glfs_t', 'string', 'string'] => 'int');
    $glfs_ffi->attach(glfs_fremovexattr => ['opaque', 'string'] => 'int');
    $glfs_ffi->attach(glfs_fallocate => ['opaque', 'int', 'size_t'] => 'int');
    $glfs_ffi->attach(glfs_discard => ['opaque', 'int', 'size_t'] => 'int');
    #$glfs_ffi->attach(glfs_discard_async => ['opaque', 'int', 'size_t'] => 'int');
    $glfs_ffi->attach(glfs_zerofill => ['opaque', 'int', 'size_t'] => 'int');
    #$glfs_ffi->attach(glfs_zerofill_async => ['opaque', 'int', 'size_t'] => 'int');
    $glfs_ffi->attach(glfs_getcwd => ['glfs_t', 'string', 'size_t'] => 'string');
    $glfs_ffi->attach(glfs_chdir => ['glfs_t', 'string'] => 'int');
    $glfs_ffi->attach(glfs_fchdir => ['opaque'] => 'int');
    $glfs_ffi->attach(glfs_realpath => ['glfs_t', 'string', 'string'] => 'string');
    $glfs_ffi->attach(glfs_posix_lock => ['opaque', 'int', 'opaque'] => 'int');
    $glfs_ffi->attach(glfs_dup => ['opaque'] => 'opaque');

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

