# libgfapi-perl

[![Build Status](https://travis-ci.org/potatogim/libgfapi-perl.svg?branch=master)](https://travis-ci.org/potatogim/libgfapi-perl)

GlusterFS libgfapi binding for Perl 5

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
| [o] | [x] | glfs_fsync() |
| [x] | [x] | glfs_fsync_async() |
| [o] | [x] | glfs_fdatasync() |
| [x] | [x] | glfs_fdatasync_async() |
| [o] | [x] | glfs_access() |
| [o] | [x] | glfs_symlink() |
| [o] | [x] | glfs_readlink() |
| [x] | [x] | glfs_mknod() |
| [o] | [o] | glfs_mkdir() |
| [o] | [o] | glfs_unlink() |
| [o] | [o] | glfs_rmdir() |
| [o] | [x] | glfs_rename() |
| [o] | [x] | glfs_link() |
| [o] | [o] | glfs_opendir() |
| [o] | [o] | glfs_readdir_r() |
| [o] | [o] | glfs_readdirplus_r() |
| [o] | [x] | glfs_readdir() |
| [o] | [x] | glfs_readdirplus() |
| [o] | [x] | glfs_telldir() |
| [o] | [x] | glfs_seekdir() |
| [o] | [o] | glfs_closedir() |
| [o] | [o] | glfs_statvfs() |
| [o] | [x] | glfs_chmod() |
| [o] | [x] | glfs_fchmod() |
| [o] | [x] | glfs_chown() |
| [o] | [x] | glfs_lchown() |
| [o] | [x] | glfs_fchown() |
| [o] | [o] | glfs_utimens() |
| [o] | [o] | glfs_lutimens() |
| [o] | [o] | glfs_futimens() |
| [o] | [x] | glfs_getxattr() |
| [o] | [x] | glfs_lgetxattr() |
| [o] | [x] | glfs_fgetxattr() |
| [o] | [x] | glfs_listxattr() |
| [o] | [x] | glfs_llistxattr() |
| [o] | [x] | glfs_flistxattr() |
| [o] | [x] | glfs_setxattr() |
| [o] | [x] | glfs_lsetxattr() |
| [o] | [x] | glfs_fsetxattr() |
| [o] | [x] | glfs_removexattr() |
| [o] | [x] | glfs_lremovexattr() |
| [o] | [x] | glfs_fremovexattr() |
| [o] | [x] | glfs_fallocate() |
| [o] | [x] | glfs_discard() |
| [x] | [x] | glfs_discard_async() |
| [o] | [x] | glfs_zerofill() |
| [x] | [x] | glfs_zerofill_async() |
| [o] | [x] | glfs_getcwd() |
| [o] | [x] | glfs_chdir() |
| [o] | [x] | glfs_fchdir() |
| [o] | [x] | glfs_realpath() |
| [o] | [x] | glfs_posix_lock() |
| [o] | [x] | glfs_dup() |
