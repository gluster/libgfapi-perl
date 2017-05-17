#/usr/bin/env perl

use strict;
use warnings;
use utf8;

use POSIX       qw/:fcntl_h/;
use Test::Most;
use Data::Dumper;
use Devel::Peek;

use FFI::Platypus;
use FFI::Platypus::Memory   qw/malloc free/;

diag('00-basic.t');

use_ok('GlusterFS::GFAPI::FFI');

my $api = GlusterFS::GFAPI::FFI->new();

ok(defined($api) && ref($api) eq 'GlusterFS::GFAPI::FFI'
    , 'GlusterFS::GFAPI::FFI - new()');

# new
my $fs = GlusterFS::GFAPI::FFI::glfs_new('libgfapi-perl');

ok(defined($fs), sprintf('glfs_new(): %s', $fs // 'undef'));

my $retval;

# set_volfile_server
$retval = GlusterFS::GFAPI::FFI::glfs_set_volfile_server($fs, 'tcp', 'node1', 24007);

ok($retval == 0, sprintf('glfs_set_volfile_server(): %d', $retval));

# init
$retval = GlusterFS::GFAPI::FFI::glfs_init($fs);

ok($retval == 0, sprintf('glfs_init(): %d', $retval));

# get_volumeid
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

$retval = GlusterFS::GFAPI::FFI::glfs_get_volumeid($fs, $id, $len);

$id = join('-', unpack('H8 H4 H4 H4 H12', $id));

cmp_ok($retval, '==', $len, sprintf('glfs_get_volumeid(): %d', $retval));
cmp_ok($id, 'eq', $expected, sprintf('	Volume ID : %s', $id // 'undef'));

# statvfs
my $stat = GlusterFS::GFAPI::FFI::Statvfs->new();

$retval = GlusterFS::GFAPI::FFI::glfs_statvfs($fs, '/', $stat);

ok(defined($stat), sprintf('glfs_statvfs(): %d', $retval // 'undef'));

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

# creat
my $fd = GlusterFS::GFAPI::FFI::glfs_creat($fs, '/testfile', O_RDWR, 0644);

ok(defined($fd), sprintf('glfs_creat(): %s', $fd // 'undef'));

ok(`ls -al /mnt/libgfapi-perl` =~ m/-rw.+ testfile\n/, 'testfile has exsits');

# from_glfd
my $glfs = GlusterFS::GFAPI::FFI::glfs_from_glfd($fd);

ok(defined($glfs) && $glfs == $fs, sprintf('glfs_from_glfd(): %s', $glfs // 'undef'));

undef($fd);

# set_xlator_option
$retval = GlusterFS::GFAPI::FFI::glfs_set_xlator_option($fs, '*-write-behind', 'resync-faield-syncs-after-fsync', 'on');

ok($retval == 0, sprintf('glfs_set_xlator_option: %s', $retval // 'undef'));

# open
$fd = GlusterFS::GFAPI::FFI::glfs_open($fs, '/testfile', O_RDWR);

# close
$retval = GlusterFS::GFAPI::FFI::glfs_close($fd);

ok($retval == 0, sprintf('glfs_close(): %s', $retval // 'undef'));

$stat = GlusterFS::GFAPI::FFI::Stat->new();

# lstat
$retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, '/testfile', $stat);

ok($retval == 0, sprintf('glfs_lstat(): %d', $retval // 'undef'));

ok(defined($stat->st_ino),     "	ino     : " . $stat->st_ino // 'undef');
ok(defined($stat->st_mode),    "	mode    : " . $stat->st_mode // 'undef');
ok(defined($stat->st_size),    "	size    : " . $stat->st_size // 'undef');
ok(defined($stat->st_blksize), "	blksize : " . $stat->st_blksize // 'undef');
ok(defined($stat->st_uid),     "	uid     : " . $stat->st_uid // 'undef');
ok(defined($stat->st_gid),     "	gid     : " . $stat->st_gid // 'undef');
ok(defined($stat->st_atime),   "	atime   : " . $stat->st_atime // 'undef');
ok(defined($stat->st_mtime),   "	mtime   : " . $stat->st_mtime // 'undef');
ok(defined($stat->st_ctime),   "	ctime   : " . $stat->st_ctime // 'undef');

# mkdir
$retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, '/testdir', 0644);

ok($retval == 0, sprintf('glfs_mkdir(): %s', $retval // 'undef'));

map
{
    $retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, "$_", 0644);

    ok($retval == 0, sprintf('glfs_mkdir(): %s', $retval // 'undef'));
    ok(`ls -al /mnt/libgfapi-perl` =~ m/drw.* $_\n/, "$_ has exists");
} qw/a b c d/;

# opendir
$fd = GlusterFS::GFAPI::FFI::glfs_opendir($fs, '/');

ok(defined($fd), sprintf('glfs_opendir(): %s', $fd // 'undef'));

# readdir_r
my $entry  = GlusterFS::GFAPI::FFI::Dirent->new(d_reclen => 256);
my $result = GlusterFS::GFAPI::FFI::Dirent->new();

while (!($retval
        = GlusterFS::GFAPI::FFI::glfs_readdir_r($fd, $entry, \$result)))
{
    $result = GlusterFS::GFAPI::FFI::cast_Dirent($result);

    last if (!defined($result));

    ok($retval == 0, sprintf("glfs_readdir_r(): %s", $retval // 'undef'));
    ok(defined($result), sprintf('DIR: %s', $result->d_name));

    map
    {
        ok(defined($result->$_)
            , sprintf('	%s : %s', $_, $result->$_ // 'undef'));
    } qw/d_ino d_off d_reclen d_type/;
}

# closedir
$retval = GlusterFS::GFAPI::FFI::glfs_closedir($fd);

ok($retval == 0, sprintf('glfs_closedir(): %s', $retval // 'undef'));

# opendir
$fd = GlusterFS::GFAPI::FFI::glfs_opendir($fs, '/');

# readdirplus_r
$stat   = GlusterFS::GFAPI::FFI::Stat->new();
$entry  = GlusterFS::GFAPI::FFI::Dirent->new(d_reclen => 256);
$result = GlusterFS::GFAPI::FFI::Dirent->new();

while (!($retval
        = GlusterFS::GFAPI::FFI::glfs_readdirplus_r($fd, $stat, $entry, \$result)))
{
    $result = GlusterFS::GFAPI::FFI::cast_Dirent($result);

    last if (!defined($result));

    ok($retval == 0, sprintf("glfs_readdirplus_r(): %s", $retval // 'undef'));
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

# closedir
$retval = GlusterFS::GFAPI::FFI::glfs_closedir($fd);

# rmdir
map
{
    $retval = GlusterFS::GFAPI::FFI::glfs_rmdir($fs, "$_", 0644);

    ok($retval == 0, sprintf('glfs_rmdir(): %s', $retval // 'undef'));
    ok(`ls -al /mnt/libgfapi-perl` !~ m/drw.* $_\n/, "$_ does not exists");
} qw/a b c d/;

# fini
$retval = GlusterFS::GFAPI::FFI::glfs_fini($fs);

done_testing();
