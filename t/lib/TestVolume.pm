package TestVolume;

use base qw/Test Test::Class/;

use Test::Most;
use GlusterFS::GFAPI::FFI;
use GlusterFS::GFAPI::FFI::Volume;

sub setup : Test(setup)
{
    my $self = shift;

    diag("setup");

    no warnings 'redefine';

    $self->{_saved_glfs_new} = \&GlusterFS::GFAPI::FFI::glfs_new;
    ${GlusterFS::GFAPI::FFI::}{glfs_new} = \&Test::_mock_glfs_new;

    $self->{_saved_glfs_set_volfile_server} = \&GlusterFS::GFAPI::FFI::glfs_set_volfile_server;
    ${GlusterFS::GFAPI::FFI::}{glfs_set_volfile_server} = \&Test::_mock_glfs_set_volfile_server;

    $self->{_saved_glfs_init} = \&GlusterFS::GFAPI::FFI::glfs_init;
    ${GlusterFS::GFAPI::FFI::}{glfs_init} = \&Test::_mock_glfs_init;

    $self->{_saved_glfs_fini} = \&GlusterFS::GFAPI::FFI::glfs_fini;
    ${GlusterFS::GFAPI::FFI::}{glfs_fini} = \&Test::_mock_glfs_fini;

    $self->{_saved_glfs_close} = \&GlusterFS::GFAPI::FFI::glfs_close;
    ${GlusterFS::GFAPI::FFI::}{glfs_close} = \&Test::_mock_glfs_close;

    $self->{_saved_glfs_closedir} = \&GlusterFS::GFAPI::FFI::glfs_closedir;
    ${GlusterFS::GFAPI::FFI::}{glfs_closedir} = \&Test::_mock_glfs_closedir;

    $self->{_saved_glfs_set_logging} = \&GlusterFS::GFAPI::FFI::glfs_set_logging;
    ${GlusterFS::GFAPI::FFI::}{glfs_set_logging} = \&Test::_mock_glfs_set_logging;

    $self->{vol} = GlusterFS::GFAPI::FFI::Volume->new(host => 'mockhost', volname => 'test');
    $self->{vol}->_set_fs(12345);
    $self->{vol}->_set_mounted(1);
}

sub teardown : Test(teardown)
{
    my $self = shift;

    diag("teardown");

    no warnings 'redefine';

    undef $self->{vol};

    map
    {
        ${GlusterFS::GFAPI::FFI::}{"glfs_$_"} = $self->{"_saved_glfs_$_"};
    } qw/new set_volfile_server init fini close closedir set_logging/;
}

sub test_initialization_error : Test
{

}

sub test_initialization_success : Test
{

}

sub test_mount_umount_success : Test
{

}

sub test_mount_multiple : Test
{

}

sub test_mount_error : Test
{

}

sub test_umount_error : Test
{

}

sub test_set_logging : Test
{

}

sub test_set_logging_err : Test
{

}

sub test_chmod_success : Test
{

}

sub test_chmod_fail_exception : Test
{

}

sub test_chown_success : Test
{

}

sub test_chown_fail_exception : Test
{

}

sub test_creat_success : Test
{

}

sub test_exists_true : Test
{

}

sub test_not_exists_false : Test
{

}

sub test_isdir_true : Test
{

}

sub test_isdir_false : Test
{

}

sub test_isdir_false_nodir : Test
{

}

sub test_isfile_true : Test
{

}

sub test_isfile_false : Test
{

}

sub test_isfile_false_nofile : Test
{

}

sub test_islink_true : Test
{

}

sub test_islink_false : Test
{

}

sub test_islink_false_nolink : Test
{

}

sub test_getxattr_success : Test
{

}

sub test_getxattr_fail_exception : Test
{

}

sub test_listdir_success : Test
{

}

sub test_listdir_fail_exception : Test
{

}

sub test_listdir_with_stat_success : Test
{

}

sub test_listdir_with_fail_exception : Test
{

}

sub test_scandir_success : Test
{

}

sub test_listxattr_success : Test
{

}

sub test_lstat_success : Test
{

}

sub test_lstat_fail_exception : Test
{

}

sub test_stat_success : Test
{

}

sub test_stat_fail_exception : Test
{

}

sub test_statvfs_success : Test
{

}

sub test_statvfs_fail_exception : Test
{

}

sub test_makedirs_success : Test
{

}

sub test_makedirs_success_EEXIST : Test
{

}

sub test_makedirs_fail_exception : Test
{

}

sub test_mkdir_success : Test
{

}

sub test_mkdir_fail_exception : Test
{

}

sub test_open_with_statement_success : Test
{

}

sub test_open_with_statement_fail_exception : Test
{

}

sub test_open_direct_success : Test
{

}

sub test_open_direct_fail_exception : Test
{

}

sub test_opendir_success : Test
{

}

sub test_opendir_fail_exception : Test
{

}

sub test_rename_success : Test
{

}

sub test_rename_fail_exception : Test
{

}

sub test_rmdir_success : Test
{

}

sub test_rmdir_fail_exception : Test
{

}

sub test_unlink_success : Test
{

}

sub test_unlink_fail_exception : Test
{

}

sub test_removexattr_success : Test
{

}

sub test_removexattr_fail_exception : Test
{

}

sub test_rmtree_success : Test
{

}

sub test_rmtree_listdir_exception : Test
{

}

sub test_rmtree_islink_exception : Test
{

}

sub test_rmtree_ignore_unlink_rmdir_exception : Test
{

}

sub test_setfsuid_success : Test
{

}

sub test_setfsuid_fail_exception : Test
{

}

sub test_setfsgid_success : Test
{

}

sub test_setfsgid_fail_exception : Test
{

}

sub test_setxattr_success : Test
{

}

sub test_setxattr_fail_exception : Test
{

}

sub test_symlink_success : Test
{

}

sub test_symlink_fail_exception : Test
{

}

sub test_walk_success : Test
{

}

sub test_walk_scandir_exception : Test
{

}

sub test_copytree_success : Test
{

}

sub test_utime : Test
{

}

1;
