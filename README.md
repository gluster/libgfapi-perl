# libgfapi-perl [![Build Status](https://travis-ci.org/potatogim/libgfapi-perl.svg?branch=master)](https://travis-ci.org/potatogim/libgfapi-perl)

GlusterFS libgfapi binding for Perl 5

The libgfapi-perl provides declarations and linkage for the Gluster gfapi C library with FFI for many Perl mongers.

To use it, you can use test code that exists under 't/' directory for reference.

## Pre-installed requirements

This binding is using libgfapi. It means that you should install libraries before using this.


Please follow steps;
```sh
sudo yum -y install glusterfs-devel glusterfs-api-devel
```

## Not yet supported

### Asynchronous I/O

libgfapi-perl does not support some asynchronous I/O functions that using closure(callback) yet.

* ```glfs_read_async()```
* ```glfs_write_async()```
* ```glfs_readv_async()```
* ```glfs_writev_async()```
* ```glfs_pread_async()```
* ```glfs_pwrite_async()```
* ```glfs_preadv_async()```
* ```glfs_pwritev_async()```
* ```glfs_ftruncate_async()```
* ```glfs_fsync_async()```
* ```glfs_fdatasync_async()```
* ```glfs_discard_async()```
* ```glfs_zerofill_async()```

## AUTHOR

Author: Ji-Hyeon Gim ([@potatogim](https://github.com/potatogim))

Contributors

- Tae-Hwa Lee ([@alghost](https://github.com/alghost))

## COPYRIGHT AND LICENSE

This software is copyright 2017-2018 by Ji-Hyeon Gim.

This is free software; you can redistribute it and/or modify it under the same terms as the GPLv2/LGPLv3.

