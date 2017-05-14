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

sub new
{
    my $ffi = FFI::Platypus->new(lib => libgfapi_soname());

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

