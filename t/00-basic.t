#/usr/bin/env perl

use strict;
use warnings;
use utf8;

use POSIX       qw/:fcntl_h/;
use Test::Most;
use Data::Dumper;
use Devel::Peek;

use FFI::Platypus;
use FFI::Platypus::Memory   qw/strdup calloc free/;
use FFI::Platypus::Declare;

diag('00-basic.t');

use_ok('GlusterFS::GFAPI::FFI');

my $api = GlusterFS::GFAPI::FFI->new();

ok(defined($api) && ref($api) eq 'GlusterFS::GFAPI::FFI'
    , 'GlusterFS::GFAPI::FFI - new()');

# new
my $fs;

subtest 'new' => sub
{
    $fs = GlusterFS::GFAPI::FFI::glfs_new('libgfapi-perl');

    ok(defined($fs), sprintf('glfs_new(): %s', $fs // 'undef'));
};

# set_volfile_server
subtest 'set_volfile_server' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_set_volfile_server($fs, 'tcp', 'node1', 24007);

    ok($retval == 0, sprintf('glfs_set_volfile_server(): %d', $retval));
};

# init
subtest 'init' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_init($fs);

    ok($retval == 0, sprintf('glfs_init(): %d', $retval));
};

# get_volumeid
subtest 'get_volumeid' => sub
{
    my $expected;

    do {
        my $out = `sudo gluster volume info libgfapi-perl`;

        foreach (split(/\n/, $out))
        {
            if ($_ =~ m/^Volume ID: (?<volid>[^\s]+)$/)
            {
                $expected = $+{volid};
                last;
            }
        }
    };

    my $len = 16;
    my $id  = "\0" x $len;

    my $retval = GlusterFS::GFAPI::FFI::glfs_get_volumeid($fs, $id, $len);

    $id = join('-', unpack('H8 H4 H4 H4 H12', $id));

    cmp_ok($retval, '==', $len, sprintf('glfs_get_volumeid(): %d', $retval));
    cmp_ok($id, 'eq', $expected, sprintf('	Volume ID : %s', $id // 'undef'));
};

# statvfs
subtest 'statvfs' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Statvfs->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_statvfs($fs, '/', $stat);

    ok(defined($stat), sprintf('glfs_statvfs(): %d', $retval));

    ok(defined($stat->f_bsize),   "	f_bsize   : " . $stat->f_bsize   // 'undef');
    ok(defined($stat->f_frsize),  "	f_frsize  : " . $stat->f_frsize  // 'undef');
    ok(defined($stat->f_blocks),  "	f_blocks  : " . $stat->f_blocks  // 'undef');
    ok(defined($stat->f_bfree),   "	f bfree   : " . $stat->f_bfree   // 'undef');
    ok(defined($stat->f_bavail),  "	f_bavail  : " . $stat->f_bavail  // 'undef');
    ok(defined($stat->f_files),   "	f_files   : " . $stat->f_files   // 'undef');
    ok(defined($stat->f_ffree),   "	f_ffree   : " . $stat->f_ffree   // 'undef');
    ok(defined($stat->f_favail),  "	f_favail  : " . $stat->f_favail  // 'undef');
    ok(defined($stat->f_fsid),    "	f_fsid    : " . $stat->f_fsid    // 'undef');
    ok(defined($stat->f_flag),    "	f_flag    : " . $stat->f_flag    // 'undef');
    ok(defined($stat->f_namemax), "	f_namemax : " . $stat->f_namemax // 'undef');
    ok(defined($stat->__f_spare)
        , sprintf('	__f_spare : %s'
            , defined($stat->__f_spare)
                ? '[' . join(', ', @{$stat->__f_spare}) . ']'
                : 'undef'));
};

# creat
my $fd;

subtest 'creat' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_creat($fs, '/testfile', O_RDWR, 0644);

    ok(defined($fd), sprintf('glfs_creat(): %s', $fd // 'undef'));

    ok(`ls -al /mnt/libgfapi-perl` =~ m/-rw.+ testfile\n/, 'testfile has exsits');
};

# stat
subtest 'stat' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_stat($fs, '/testfile', $stat);

    ok($retval == 0, sprintf('glfs_stat(): %d', $retval));

    ok(defined($stat->st_ino),     "	ino     : " . $stat->st_ino // 'undef');
    ok(defined($stat->st_mode),    "	mode    : " . $stat->st_mode // 'undef');
    ok(defined($stat->st_size),    "	size    : " . $stat->st_size // 'undef');
    ok(defined($stat->st_blksize), "	blksize : " . $stat->st_blksize // 'undef');
    ok(defined($stat->st_uid),     "	uid     : " . $stat->st_uid // 'undef');
    ok(defined($stat->st_gid),     "	gid     : " . $stat->st_gid // 'undef');
    ok(defined($stat->st_atime),   "	atime   : " . $stat->st_atime // 'undef');
    ok(defined($stat->st_mtime),   "	mtime   : " . $stat->st_mtime // 'undef');
    ok(defined($stat->st_ctime),   "	ctime   : " . $stat->st_ctime // 'undef');
};

# lstat
subtest 'lstat' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, '/testfile', $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    ok(defined($stat->st_ino),     "	ino     : " . $stat->st_ino // 'undef');
    ok(defined($stat->st_mode),    "	mode    : " . $stat->st_mode // 'undef');
    ok(defined($stat->st_size),    "	size    : " . $stat->st_size // 'undef');
    ok(defined($stat->st_blksize), "	blksize : " . $stat->st_blksize // 'undef');
    ok(defined($stat->st_uid),     "	uid     : " . $stat->st_uid // 'undef');
    ok(defined($stat->st_gid),     "	gid     : " . $stat->st_gid // 'undef');
    ok(defined($stat->st_atime),   "	atime   : " . $stat->st_atime // 'undef');
    ok(defined($stat->st_mtime),   "	mtime   : " . $stat->st_mtime // 'undef');
    ok(defined($stat->st_ctime),   "	ctime   : " . $stat->st_ctime // 'undef');
};

# from_glfd
subtest 'from_glfd' => sub
{
    my $glfs = GlusterFS::GFAPI::FFI::glfs_from_glfd($fd);

    ok(defined($glfs) && $glfs == $fs
        , sprintf('glfs_from_glfd(): %s', $glfs // 'undef'));
};

undef($fd);

# set_xlator_option
subtest 'set_xlator_option' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_set_xlator_option(
                $fs,
                '*-write-behind',
                'resync-failed-syncs-after-fsync',
                'on');

    ok($retval == 0, sprintf('glfs_set_xlator_option(): %d', $retval));
};

# open
subtest 'open' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_open($fs, '/testfile', O_RDWR);

    ok($fd, sprintf('glfs_open(): %d', $fd));
};

# fstat
subtest 'fstat' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_fstat($fd, $stat);

    ok($retval == 0, sprintf('glfs_fstat(): %d', $retval));

    ok(defined($stat->st_ino),     "	ino     : " . $stat->st_ino // 'undef');
    ok(defined($stat->st_mode),    "	mode    : " . $stat->st_mode // 'undef');
    ok(defined($stat->st_size),    "	size    : " . $stat->st_size // 'undef');
    ok(defined($stat->st_blksize), "	blksize : " . $stat->st_blksize // 'undef');
    ok(defined($stat->st_uid),     "	uid     : " . $stat->st_uid // 'undef');
    ok(defined($stat->st_gid),     "	gid     : " . $stat->st_gid // 'undef');
    ok(defined($stat->st_atime),   "	atime   : " . $stat->st_atime // 'undef');
    ok(defined($stat->st_mtime),   "	mtime   : " . $stat->st_mtime // 'undef');
    ok(defined($stat->st_ctime),   "	ctime   : " . $stat->st_ctime // 'undef');
};

# write
subtest 'write' => sub
{
    my $text   = 'This is a lipsum';
    my $len    = length($text);
    my $buffer = strdup($text);
    my $retval = GlusterFS::GFAPI::FFI::glfs_write($fd, $buffer, $len, 0);

    ok($retval > 0, sprintf('glfs_write(): %d', $retval));

    free($buffer);
};

# lseek
subtest 'lseek' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_lseek($fd, 0, 0);

    ok($retval == 0, sprintf('glfs_lseek(): %d', $retval));
};

# read
subtest 'read' => sub
{
    my $buffer = calloc(256, 1);
    my $retval = GlusterFS::GFAPI::FFI::glfs_read($fd, $buffer, 256, 0);

    ok($retval > 0, sprintf('glfs_read(): %s(%d)', cast('opaque' => 'string', $buffer), $retval));

    free($buffer);
};

# lseek
subtest 'lseek' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_lseek($fd, 0, 0);

    ok($retval == 0, sprintf('glfs_lseek(): %d', $retval));
};

# pwrite
subtest 'pwrite' => sub
{
    my $retval = 0;

    ok($retval == 0, sprintf('glfs_pwrite(): %d', $retval));
};

# lseek
subtest 'lseek' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_lseek($fd, 0, 0);

    ok($retval == 0, sprintf('glfs_lseek(): %d', $retval));
};

# pread
subtest 'pread' => sub
{
    my $retval = 0;

    ok($retval == 0, sprintf('glfs_pread(): %d', $retval));
};

# close
subtest 'close' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_close($fd);

    ok($retval == 0, sprintf('glfs_close(): %d', $retval));
};

# mkdir
subtest 'mkdir' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, '/testdir', 0644);

    ok($retval == 0, sprintf('glfs_mkdir(): %d', $retval));

    map
    {
        $retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, "$_", 0644);

        ok($retval == 0, sprintf('glfs_mkdir(): %d', $retval));
        ok(`ls -al /mnt/libgfapi-perl` =~ m/drw.* $_\n/, "$_ has exists");
    } qw/a b c d/;
};

# opendir
subtest 'opendir' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_opendir($fs, '/');

    ok(defined($fd), sprintf('glfs_opendir(): %s', $fd // 'undef'));
};

# readdir_r
subtest 'readdir_r' => sub
{
    my $entry = GlusterFS::GFAPI::FFI::Dirent->new(d_reclen => 256);
    my $result = GlusterFS::GFAPI::FFI::Dirent->new();

    while (!(my $retval
            = GlusterFS::GFAPI::FFI::glfs_readdir_r($fd, $entry, \$result)))
    {
        $result = GlusterFS::GFAPI::FFI::cast_Dirent($result);

        last if (!defined($result));

        ok($retval == 0, sprintf("glfs_readdir_r(): %d", $retval));
        ok(defined($result), sprintf('DIR: %s', $result->d_name));

        map
        {
            ok(defined($result->$_)
                , sprintf('	%s : %s', $_, $result->$_ // 'undef'));
        } qw/d_ino d_off d_reclen d_type/;
    }
};

# closedir
subtest 'closedir' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_closedir($fd);

    ok($retval == 0, sprintf('glfs_closedir(): %d', $retval));
};

# opendir
subtest 'opendir' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_opendir($fs, '/');

    ok($fd, sprintf('glfs_opendir(): %d', $fd));
};

# readdirplus_r
subtest 'readdirplus_r' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $entry  = GlusterFS::GFAPI::FFI::Dirent->new(d_reclen => 256);
    my $result = GlusterFS::GFAPI::FFI::Dirent->new();

    while (!(my $retval
            = GlusterFS::GFAPI::FFI::glfs_readdirplus_r($fd, $stat, $entry, \$result)))
    {
        $result = GlusterFS::GFAPI::FFI::cast_Dirent($result);

        last if (!defined($result));

        ok($retval == 0, sprintf("glfs_readdirplus_r(): %d", $retval));
        ok(defined($result), sprintf('DIR: %s', $result->d_name));

        map
        {
            ok(defined($result->$_)
                , sprintf('	%s : %s', $_, $result->$_ // 'undef'));
        } qw/d_ino d_off d_reclen d_type/;

        ok(defined($stat), sprintf('STAT: %s', $result->d_name));

        ok(defined($stat->st_ino),     "	ino     : " . $stat->st_ino // 'undef');
        ok(defined($stat->st_mode),    "	mode    : " . $stat->st_mode // 'undef');
        ok(defined($stat->st_size),    "	size    : " . $stat->st_size // 'undef');
        ok(defined($stat->st_blksize), "	blksize : " . $stat->st_blksize // 'undef');
        ok(defined($stat->st_uid),     "	uid     : " . $stat->st_uid // 'undef');
        ok(defined($stat->st_gid),     "	gid     : " . $stat->st_gid // 'undef');
        ok(defined($stat->st_atime),   "	atime   : " . $stat->st_atime // 'undef');
        ok(defined($stat->st_mtime),   "	mtime   : " . $stat->st_mtime // 'undef');
        ok(defined($stat->st_ctime),   "	ctime   : " . $stat->st_ctime // 'undef');
    }
};

# closedir
subtest 'closedir' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_closedir($fd);

    ok($retval == 0, sprintf('glfs_closedir(): %d', $retval));
};

# rmdir
subtest 'rmdir' => sub
{
    map
    {
        my $retval = GlusterFS::GFAPI::FFI::glfs_rmdir($fs, "$_", 0644);

        ok($retval == 0, sprintf('glfs_rmdir(): %d', $retval));
        ok(`ls -al /mnt/libgfapi-perl` !~ m/drw.* $_\n/, "$_ does not exists");
    } qw/a b c d/;
};

# fini
subtest 'fini' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_fini($fs);

    ok($retval == 0, sprintf('glfs_fini(): %d', $retval));
};

done_testing();
