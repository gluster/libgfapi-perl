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

    diag("error: $!") if ($retval);
};

# init
subtest 'init' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_init($fs);

    ok($retval == 0, sprintf('glfs_init(): %d', $retval));

    diag("error: $!") if ($retval);
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

    diag("error: $!") if ($retval);

    cmp_ok($id, 'eq', $expected, sprintf('	Volume ID : %s', $id // 'undef'));
};

# statvfs
subtest 'statvfs' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Statvfs->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_statvfs($fs, '/', $stat);

    ok(defined($stat), sprintf('glfs_statvfs(): %d', $retval));

    diag("error: $!") if ($retval);

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
my $fname = 'testfile';
my $fd;

subtest 'creat' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_creat($fs, "/$fname", O_RDWR, 0644);

    ok(defined($fd), sprintf('glfs_creat(): %s', $fd // 'undef'));

    ok(`ls -al /mnt/libgfapi-perl` =~ m/-rw.+ $fname\n/, "$fname has exsits");
};

# stat
subtest 'stat' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_stat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_stat(): %d', $retval));

    diag("error: $!") if ($retval);

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
    my $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

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

    diag("error: $!") if ($retval);
};

# open
subtest 'open' => sub
{
    $fd = GlusterFS::GFAPI::FFI::glfs_open($fs, "/$fname", O_RDWR);

    ok($fd, sprintf('glfs_open(): %d', $fd));
};

# fstat
subtest 'fstat' => sub
{
    my $stat   = GlusterFS::GFAPI::FFI::Stat->new();
    my $retval = GlusterFS::GFAPI::FFI::glfs_fstat($fd, $stat);

    ok($retval == 0, sprintf('glfs_fstat(): %d', $retval));

    diag("error: $!") if ($retval);

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

# utimens
subtest 'utimens' => sub
{
    sleep 5;

    my $ts     = time;
    my $tspecs = GlusterFS::GFAPI::FFI::Timespecs->new(atime_sec => $ts, mtime_sec => $ts);
    my $retval = GlusterFS::GFAPI::FFI::glfs_utimens($fs, "/$fname", $tspecs);

    ok($retval == 0, sprintf('glfs_utimens(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    cmp_ok($stat->st_atime, '==', $ts, "last access time validation");
    cmp_ok($stat->st_mtime, '==', $ts, "modification time validation");
};

# lutimens
subtest 'lutimens' => sub
{
    sleep 5;

    my $ts     = time;
    my $tspecs = GlusterFS::GFAPI::FFI::Timespecs->new(atime_sec => $ts, mtime_sec => $ts);
    my $retval = GlusterFS::GFAPI::FFI::glfs_lutimens($fs, "/$fname", $tspecs);

    ok($retval == 0, sprintf('glfs_lutimens(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    cmp_ok($stat->st_atime, '==', $ts, "last access time validation");
    cmp_ok($stat->st_mtime, '==', $ts, "modification time validation");
};

# futimens
subtest 'futimens' => sub
{
    # :TODO 2018/01/29 22:54:29 by P.G.
    # We need the code to check compatibility of futimes().
    # - https://www.mail-archive.com/gluster-devel@nongnu.org/msg11327.html
    diag("Skip glfs_futimens() because compatibility issue");
    diag('- https://www.mail-archive.com/gluster-devel@nongnu.org/msg11327.html');

    ok(1, 'glfs_futimens(): skipped');

    return;

    sleep 5;

    my $ts     = time;
    my $tspecs = GlusterFS::GFAPI::FFI::Timespecs->new(atime_sec => $ts, mtime_sec => $ts);
    my $retval = GlusterFS::GFAPI::FFI::glfs_futimens($fd, $tspecs);

    ok($retval == 0, sprintf('glfs_futimens(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    cmp_ok($stat->st_atime, '==', $ts, "last access time validation");
    cmp_ok($stat->st_mtime, '==', $ts, "modification time validation");
};

# write
subtest 'write' => sub
{
    my $text   = 'This is a lipsum';
    my $len    = length($text);
    my $buffer = strdup($text);
    my $retval = GlusterFS::GFAPI::FFI::glfs_write($fd, $buffer, $len, 0);

    ok($retval > 0, sprintf('glfs_write(): %d', $retval));

    diag("error: $!") if ($retval < 0);

    free($buffer);
};

# lseek
subtest 'lseek' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_lseek($fd, 0, 0);

    ok($retval == 0, sprintf('glfs_lseek(): %d', $retval));

    diag("error: $!") if ($retval);
};

# read
subtest 'read' => sub
{
    my $buffer = calloc(256, 1);
    my $retval = GlusterFS::GFAPI::FFI::glfs_read($fd, $buffer, 256, 0);

    ok($retval > 0, sprintf('glfs_read(): %s(%d)', cast('opaque' => 'string', $buffer), $retval));

    diag("error: $!") if ($retval < 0);

    free($buffer);
};

# truncate
subtest 'truncate' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_truncate($fs, "/$fname", 0);

    ok($retval == 0, sprintf('glfs_truncate(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    cmp_ok($stat->st_size, '==', 0, '	size : ' . $stat->st_size // 'undef');
};

# pwrite
subtest 'pwrite' => sub
{
    my $text   = 'This is a lipsum';
    my $len    = length($text);
    my $buffer = strdup($text);
    my $retval = GlusterFS::GFAPI::FFI::glfs_pwrite($fd, $buffer, $len, 100);

    ok($retval > 0, sprintf('glfs_pwrite(): %d', $retval));

    diag("error: $!") if ($retval < 0);

    free($buffer);
};

# fsync
subtest 'fsync' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_fsync($fd);

    ok($retval == 0, sprintf('glfs_fsync(): %d', $retval));

    diag("error: $!") if ($retval);
};

# fdatasync
subtest 'fdatasync' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_fdatasync($fd);

    ok($retval == 0, sprintf('glfs_fdatasync(): %d', $retval));

    diag("error: $!") if ($retval);
};

# pread
subtest 'pread' => sub
{
    my $buffer = calloc(256, 1);
    my $retval = GlusterFS::GFAPI::FFI::glfs_pread($fd, $buffer, 256, 100);

    ok($retval > 0, sprintf('glfs_pread(): %s(%d)', cast('opaque' => 'string', $buffer), $retval));

    diag("error: $!") if ($retval < 0);

    free($buffer);
};

# ftruncate
subtest 'ftruncate' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_ftruncate($fd, 0);

    ok($retval == 0, sprintf('glfs_ftruncate(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    cmp_ok($stat->st_size, '==', 0, '	size : ' . $stat->st_size // 'undef');
};

# chmod
subtest 'chmod' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_chmod($fs, "/$fname", 0777);

    ok($retval == 0, sprintf('glfs_chmod(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    my $perm = $stat->st_mode & (S_IRWXU | S_IRWXG | S_IRWXO);

    cmp_ok($perm, '==', 0777, '	mode : ' . sprintf('%o', $perm));
};

# fchmod
subtest 'fchmod' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_fchmod($fd, 0644);

    ok($retval == 0, sprintf('glfs_fchmod(): %d', $retval));

    diag("error: $!") if ($retval);

    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    my $perm = $stat->st_mode & (S_IRWXU | S_IRWXG | S_IRWXO);

    cmp_ok($perm, '==', 0644, '	mode : ' . sprintf('%o', $perm));
};

# close
subtest 'close' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_close($fd);

    ok($retval == 0, sprintf('glfs_close(): %d', $retval));

    diag("error: $!") if ($retval);
};

# access
subtest 'access' => sub
{
    my $stat = GlusterFS::GFAPI::FFI::Stat->new();

    my $retval = GlusterFS::GFAPI::FFI::glfs_lstat($fs, "/$fname", $stat);

    ok($retval == 0, sprintf('glfs_lstat(): %d', $retval));

    diag("error: $!") if ($retval);

    my $perm = $stat->st_mode & (S_IRWXU | S_IRWXG | S_IRWXO);

    cmp_ok($perm, '==', 0644, '	mode : ' . sprintf('%o', $perm));

    no strict 'refs';

    # This is a trick to invalidate cache for this file
    system('ls -al /mnt/libgfapi-perl 2>&1 1>/dev/null');

    map
    {
        $retval = GlusterFS::GFAPI::FFI::glfs_access($fs, "/$fname", *{"POSIX::$_"}{CODE}->());

        ok(($_ eq 'X_OK' ? abs($retval) : !$retval),
            sprintf('glfs_access(%s): %d', $_, $retval));

        diag("error: $!") if ($retval);
    } ('F_OK', 'R_OK', 'W_OK', 'X_OK');

    use strict 'refs';

    return;
};

# mkdir
subtest 'mkdir' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, '/testdir', 0644);

    ok($retval == 0, sprintf('glfs_mkdir(): %d', $retval));

    diag("error: $!") if ($retval);

    map
    {
        $retval = GlusterFS::GFAPI::FFI::glfs_mkdir($fs, "$_", 0644);

        ok($retval == 0, sprintf('glfs_mkdir(): %d', $retval));
        diag("error: $!") if ($retval);

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

    diag("error: $!") if ($retval);
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

    diag("error: $!") if ($retval);
};

# rmdir
subtest 'rmdir' => sub
{
    map
    {
        my $retval = GlusterFS::GFAPI::FFI::glfs_rmdir($fs, "$_", 0644);

        ok($retval == 0, sprintf('glfs_rmdir(): %d', $retval));
        diag("error: $!") if ($retval);

        ok(`ls -al /mnt/libgfapi-perl` !~ m/drw.* $_\n/, "$_ does not exists");
    } qw/a b c d/;
};

# fini
subtest 'fini' => sub
{
    my $retval = GlusterFS::GFAPI::FFI::glfs_fini($fs);

    ok($retval == 0, sprintf('glfs_fini(): %d', $retval));

    diag("error: $!") if ($retval);
};

done_testing();
