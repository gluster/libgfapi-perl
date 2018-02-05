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

| Supported | Verified | Function |
|:---------:|:--------:| -------- |
| [o] | [x] | glfs_setfsuid() |
| [o] | [x] | glfs_setfsgid() |
| [o] | [x] | glfs_setfsgroups() |
| [x] | [x] | glfs_read_async() |
| [x] | [x] | glfs_write_async() |
| [x] | [x] | glfs_readv_async() |
| [x] | [x] | glfs_writev_async() |
| [x] | [x] | glfs_pread_async() |
| [x] | [x] | glfs_pwrite_async() |
| [x] | [x] | glfs_preadv_async() |
| [x] | [x] | glfs_pwritev_async() |
| [x] | [x] | glfs_ftruncate_async() |
| [x] | [x] | glfs_fsync_async() |
| [x] | [x] | glfs_fdatasync_async() |
| [x] | [x] | glfs_discard_async() |
| [x] | [x] | glfs_zerofill_async() |
