package GlusterFS::GFAPI::FFI::File;

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
use Carp;


#---------------------------------------------------------------------------
#   Attributes
#---------------------------------------------------------------------------


#---------------------------------------------------------------------------
#   Methods
#---------------------------------------------------------------------------
sub new
{
    my $class = shift;
    my %args  = @_;
    my %attrs = ();

    bless(\%attrs, __PACKAGE__);
}

sub fileno
{
    my $self = shift;
    my %args = @_;

    return;
}

sub mode
{

    my $self = shift;
    my %args = @_;

    return;
}

sub name
{

    my $self = shift;
    my %args = @_;

    return;
}

sub closed
{

    my $self = shift;
    my %args = @_;

    return;
}

sub close
{

    my $self = shift;
    my %args = @_;

    return;
}

sub discard
{

    my $self = shift;
    my %args = @_;

    return;
}

sub dup
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fallocate
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fchmod
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fchown
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fdatasync
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fgetsize
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fgetxattr
{

    my $self = shift;
    my %args = @_;

    return;
}

sub flistxattr
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fsetxattr
{

    my $self = shift;
    my %args = @_;

    return;
}

sub fremovexattr
{
    my $self = shift;
    my %args = @_;

    return;
}

sub fstat
{
    my $self = shift;
    my %args = @_;

    return;
}

sub fsync
{
    my $self = shift;
    my %args = @_;

    return;
}

sub ftruncate
{
    my $self = shift;
    my %args = @_;

    return;
}

sub lseek
{
    my $self = shift;
    my %args = @_;

    return;
}

sub read
{
    my $self = shift;
    my %args = @_;

    return;
}

sub readinto
{
    my $self = shift;
    my %args = @_;

    return;
}

sub write
{
    my $self = shift;
    my %args = @_;

    return;
}

sub zerofill
{
    my $self = shift;
    my %args = @_;

    return;
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI::File - GFAPI File API

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

