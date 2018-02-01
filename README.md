# libgfapi-perl [![Build Status](https://travis-ci.org/potatogim/libgfapi-perl.svg?branch=master)](https://travis-ci.org/potatogim/libgfapi-perl)

GlusterFS libgfapi binding for Perl 5

The libgfapi-perl provides declarations and linkage for the Gluster gfapi C library with FFI for many Perl mongers.

## Facilities

| Supported | Verified | Function |
|:---------:|:--------:| -------- |
| [o] | [o] | glfs_init() |
| [o] | [o] | glfs_new() |
| [o] | [o] | glfs_set_volfile_server() |
| [o] | [o] | glfs_set_logging() |
| [o] | [o] | glfs_fini() |

## Features

| Supported | Verified | Function |
|:---------:|:--------:| -------- |
| [o] | [o] | glfs_get_volumeid() |
| [o] | [x] | glfs_setfsuid() |
| [o] | [x] | glfs_setfsgid() |
| [o] | [x] | glfs_setfsgroups() |
| [o] | [o] | glfs_open() |
| [o] | [o] | glfs_creat() |
| [o] | [o] | glfs_close() |
| [o] | [o] | glfs_from_glfd() |
| [o] | [o] | glfs_set_xlator_option() |
| [o] | [o] | glfs_read() |
| [o] | [o] | glfs_write() |
| [x] | [x] | glfs_read_async() |
| [x] | [x] | glfs_write_async() |
| [o] | [x] | glfs_readv() |
| [o] | [x] | glfs_writev() |
| [x] | [x] | glfs_readv_async() |
| [x] | [x] | glfs_writev_async() |
| [o] | [o] | glfs_pread() |
| [o] | [o] | glfs_pwrite() |
| [x] | [x] | glfs_pread_async() |
| [x] | [x] | glfs_pwrite_async() |
| [x] | [x] | glfs_preadv() |
| [x] | [x] | glfs_pwritev() |
| [x] | [x] | glfs_preadv_async() |
| [x] | [x] | glfs_pwritev_async() |
| [o] | [o] | glfs_lseek() |
| [o] | [o] | glfs_truncate() |
| [o] | [o] | glfs_ftruncate() |
| [x] | [x] | glfs_ftruncate_async() |
| [o] | [o] | glfs_lstat() |
| [o] | [o] | glfs_stat() |
| [o] | [o] | glfs_fstat() |
| [o] | [o] | glfs_fsync() |
| [x] | [x] | glfs_fsync_async() |
| [o] | [o] | glfs_fdatasync() |
| [x] | [x] | glfs_fdatasync_async() |
| [o] | [o] | glfs_access() |
| [o] | [o] | glfs_symlink() |
| [o] | [o] | glfs_readlink() |
| [o] | [o] | glfs_mknod() |
| [o] | [o] | glfs_mkdir() |
| [o] | [o] | glfs_unlink() |
| [o] | [o] | glfs_rmdir() |
| [o] | [o] | glfs_rename() |
| [o] | [o] | glfs_link() |
| [o] | [o] | glfs_opendir() |
| [o] | [o] | glfs_readdir_r() |
| [o] | [o] | glfs_readdirplus_r() |
| [o] | [o] | glfs_readdir() |
| [o] | [o] | glfs_readdirplus() |
| [o] | [o] | glfs_telldir() |
| [o] | [o] | glfs_seekdir() |
| [o] | [o] | glfs_closedir() |
| [o] | [o] | glfs_statvfs() |
| [o] | [o] | glfs_chmod() |
| [o] | [o] | glfs_fchmod() |
| [o] | [o] | glfs_chown() |
| [o] | [o] | glfs_lchown() |
| [o] | [o] | glfs_fchown() |
| [o] | [o] | glfs_utimens() |
| [o] | [o] | glfs_lutimens() |
| [o] | [o] | glfs_futimens() |
| [o] | [o] | glfs_getxattr() |
| [o] | [o] | glfs_lgetxattr() |
| [o] | [o] | glfs_fgetxattr() |
| [o] | [o] | glfs_listxattr() |
| [o] | [o] | glfs_llistxattr() |
| [o] | [o] | glfs_flistxattr() |
| [o] | [o] | glfs_setxattr() |
| [o] | [o] | glfs_lsetxattr() |
| [o] | [o] | glfs_fsetxattr() |
| [o] | [o] | glfs_removexattr() |
| [o] | [o] | glfs_lremovexattr() |
| [o] | [o] | glfs_fremovexattr() |
| [o] | [o] | glfs_fallocate() |
| [o] | [o] | glfs_discard() |
| [x] | [x] | glfs_discard_async() |
| [o] | [o] | glfs_zerofill() |
| [x] | [x] | glfs_zerofill_async() |
| [o] | [o] | glfs_getcwd() |
| [o] | [o] | glfs_chdir() |
| [o] | [o] | glfs_fchdir() |
| [o] | [o] | glfs_realpath() |
| [o] | [o] | glfs_posix_lock() |
| [o] | [o] | glfs_dup() |

