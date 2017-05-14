package GlusterFS::GFAPI::FFI::Volume;

BEGIN
{
    our $AUTHOR  = 'cpan:potatogim';
    our $VERSION = '0.01';
}

use strict;
use warnings;
use utf8;

use GlusterFS::GFAPI::FFI::Util qw/libgfapi_soname/;
use Carp;

use FFI::Platypus;
use FFI::Platypus::API;
use FFI::Platypus::Declare  qw/void string opaque/;
use FFI::Platypus::Memory   qw/malloc free/;
use FFI::Platypus::Buffer   qw/scalar_to_buffer buffer_to_scalar/;

sub new
{
    my $ffi = FFI::Platypus->new(lib => libgfapi_soname());

    $ffi->type('int' => 'ssize_t');

    $ffi->attach(glfs_init => ['void'], => 'int');
    $ffi->attach(glfs_new => ['string'] => 'void');
    $ffi->attach(glfs_set_volfile_server => ['void', 'string', 'string', 'int'] => 'int');
    $ffi->attach(glfs_set_logging => ['void', 'string', 'int'] => 'int');
    $ffi->attach(glfs_statvfs => ['void', 'string', 'void'], => 'int');
    $ffi->attach(glfs_fini => ['void'] => 'int');
    $ffi->attach(glfs_creat => ['void', 'string', 'int'] => 'void');
    $ffi->attach(glfs_close => ['void'] => 'int');
    $ffi->attach(glfs_lstat => ['void', 'string', 'void'] => 'int');
    $ffi->attach(glfs_stat  => ['void', 'string', 'void'] => 'int');
    $ffi->attach(glfs_fstat => ['void', 'void'] => 'int');
    $ffi->attach(glfs_chmod => ['void', 'string', 'unsigned short'] => 'int');
    $ffi->attach(glfs_fchmod => ['void', 'unsigned short'] => 'int');
    $ffi->attach(glfs_chown => ['void', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $ffi->attach(glfs_lchown => ['void', 'string', 'unsigned int', 'unsigned int'] => 'int');
    $ffi->attach(glfs_fchown => ['void', 'unsigned int', 'unsigned int'] => 'int');
    $ffi->attach(glfs_dup => ['void'] => 'void');
    $ffi->attach(glfs_fdatasync => ['void'] => 'int');
    $ffi->attach(glfs_fsync => ['void'] => 'int');
    $ffi->attach(glfs_lseek => ['void', 'int', 'int'] => 'int');
    $ffi->attach(glfs_read => ['void', 'void', 'size_t', 'int'] => 'ssize_t');
    $ffi->attach(glfs_write => ['void', 'void', 'size_t', 'int'] => 'ssize_t');
    $ffi->attach(glfs_getxattr => ['void', 'string', 'string', 'void', 'size_t'] => 'ssize_t');
    $ffi->attach(glfs_listxattr => ['void', 'string', 'void', 'size_t'] => 'ssize_t');
    $ffi->attach(glfs_removexattr => ['void', 'string', 'string'] => 'int');
    $ffi->attach(glfs_setxattr => ['void', 'string', 'string', 'void', 'size_t', 'int'] => 'int');
    $ffi->attach(glfs_rename => ['void', 'string', 'string'] => 'int');
    $ffi->attach(glfs_link => ['void', 'string', 'string'] => 'int');
    $ffi->attach(glfs_symlink => ['void', 'string', 'string'] => 'int');
    $ffi->attach(glfs_unlink => ['void', 'string'] => 'int');
    $ffi->attach(glfs_readdir_r => ['void', 'void', 'void'] => 'int');
    $ffi->attach(glfs_readdirplus_r => ['void', 'void', 'void', 'void'] => 'int');
    $ffi->attach(glfs_closedir => ['void'] => 'int');
    $ffi->attach(glfs_mkdir => ['void', 'string', 'unsigned short'] => 'int');
    $ffi->attach(glfs_opendir => ['void', 'string'] => 'void');
    $ffi->attach(glfs_rmdir => ['void', 'string'] => 'int');
    $ffi->attach(glfs_setfsuid => ['unsigned int'] => 'int');
    $ffi->attach(glfs_setfsgid => ['unsigned int'] => 'int');
    $ffi->attach(glfs_ftruncate => ['void', 'int'] => 'int');
    $ffi->attach(glfs_fgetxattr => ['void', 'string', 'void', 'size_t'] => 'ssize_t');
    $ffi->attach(glfs_fremovexattr => ['void', 'string'] => 'int');
    $ffi->attach(glfs_fsetxattr => ['void', 'string', 'void', 'size_t', 'int'] => 'int');
    $ffi->attach(glfs_flistxattr => ['void', 'void', 'size_t'] => 'ssize_t');
    $ffi->attach(glfs_access => ['void', 'string', 'int'] => 'int');
    $ffi->attach(glfs_readlink => ['void', 'string', 'string', 'size_t'] => 'int');
    $ffi->attach(glfs_chdir => ['void', 'string'] => 'int');
    $ffi->attach(glfs_getcwd => ['void', 'string', 'size_t'] => 'string');
    #$ffi->attach(glfs_fallocate => ['void', 'int', 'size_t'] => 'int');
    #$ffi->attach(glfs_discard => ['void', 'int', 'size_t'] => 'int');
    #$ffi->attach(glfs_zerofill => ['void', 'int', 'size_t'] => 'int');
    #$ffi->attach(glfs_utimens => ['void', 'string', 'void'] => 'int');

    my %attrs = ();

    bless(\%attrs, __PACKAGE__);
}

sub mounted
{

}

sub mount
{

}

sub umount
{

}

sub access
{

}

sub chdir
{

}

sub chmod
{

}

sub exists
{

}

sub getatime
{

}

sub getctime
{

}

sub getcwd
{

}

sub getmtime
{

}

sub getsize
{

}

sub getxattr
{

}

sub isdir
{

}

sub isfile
{

}

sub islink
{

}

sub listdir
{

}

sub listdir_with_stat
{

}

sub scandir
{

}

sub listxattr
{

}

sub lstat
{

}

sub makedirs
{

}

sub mkdir
{

}

sub fopen
{

}

sub open
{

}

sub opendir
{

}

sub readlink
{

}

sub remove
{

}

sub removexattr
{

}

sub rename
{

}

sub rmdir
{

}

sub rmtree
{

}

sub setfsuid
{

}

sub setfsgid
{

}

sub setxattr
{

}

sub stat
{

}

sub statvfs
{

}

sub link
{

}

sub symlink
{

}

sub unlink
{

}

sub utime
{

}

sub walk
{

}

sub samefile
{

}

sub copyfileobj
{

}

sub copyfile
{

}

sub copymode
{

}

sub copystat
{

}

sub copy
{

}

sub copy2
{

}

sub copytree
{

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

