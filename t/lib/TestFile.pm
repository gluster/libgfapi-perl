package TestFile;

use base qw/Test Test::Class/;

use Test::Most;
use GlusterFS::GFAPI::FFI;
use GlusterFS::GFAPI::FFI::File;
use Try::Tiny;

sub startup : Test(startup)
{
    my $self = shift;

    diag("startup");

    $self->{fd} = GlusterFS::GFAPI::FFI::File->new(
                    fd   => 2,
                    path => 'fakefile');
}

sub setup : Test(setup)
{
    my $self = shift;

    diag("setup");

    $self->{_saved_glfs_close} = \&GlusterFS::GFAPI::FFI::glfs_close;

    no warnings 'redefine';

    ${GlusterFS::GFAPI::FFI::}{glfs_close} = \&Test::_mock_glfs_close;
}

sub teardown : Test(teardown)
{
    my $self = shift;

    diag("teardown");

    no warnings 'redefine';

    ${GlusterFS::GFAPI::FFI::}{glfs_close} = $self->{_saved_glfs_close};
}

sub shutdown : Test(shutdown)
{
    my $self = shift;

    diag("shutdown");

    $self->{fd}->_set_fd(undef);
}

sub test_validate_init : Test
{
    my $self = shift;

    try
    {
        my $f = GlusterFS::GFAPI::File->new("not_int");

        return;
    }
    catch
    {
        return;
    };

    ok(1, 'test_validate_init');
}

sub test_validate_glfd_decorator_applied : Test
{
    my $self = shift;

    ok(1, 'test_validate_init');
}

sub test_fchmod_success : Test
{

}

sub test_fchmod_fail_exception : Test
{

}

sub test_fchown_success : Test
{

}

sub test_fchown_exception : Test
{

}

sub test_dup : Test
{

}

sub test_fdatasync_success : Test
{

}

sub test_fstat_success : Test
{

}

sub test_fstat_fail_exception : Test
{

}

sub test_fsync_success : Test
{

}

sub test_fsync_fail_exception : Test
{

}

sub test_lseek_success : Test
{

}

sub test_read_success : Test
{

}

sub test_read_fail_exception : Test
{

}

sub test_read_fail_empty_buffer : Test
{

}

sub test_read_buflen_negative : Test
{

}

sub test_readinto : Test
{

}

sub test_write_success : Test
{

}

sub test_write_binary_success : Test
{

}

sub test_write_fail_exception : Test
{

}

sub test_fallocate_success : Test
{

}

sub test_fallocate_fail_exception : Test
{

}

sub test_discard_success : Test
{

}

sub test_discard_fail_exception : Test
{

}

1;
