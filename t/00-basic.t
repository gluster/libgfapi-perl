#/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test::Most;

diag('00-basic.t');

use_ok('GlusterFS::GFAPI::FFI');
use_ok('GlusterFS::GFAPI::FFI::Volume');
use_ok('GlusterFS::GFAPI::FFI::Dir');
use_ok('GlusterFS::GFAPI::FFI::DirEntry');
use_ok('GlusterFS::GFAPI::FFI::File');

my $vol    = GlusterFS::GFAPI::FFI::Volume->new();
my $dir    = GlusterFS::GFAPI::FFI::Dir->new();
my $dirent = GlusterFS::GFAPI::FFI::DirEntry->new();
my $file   = GlusterFS::GFAPI::FFI::File->new();

ok(defined($vol) && ref($vol) eq 'GlusterFS::GFAPI::FFI::Volume'
    , 'GlusterFS::GFAPI::FFI::Volume   - new()');
ok(defined($dir) && ref($dir) eq 'GlusterFS::GFAPI::FFI::Dir'
    , 'GlusterFS::GFAPI::FFI::Dir      - new()');
ok(defined($dirent) && ref($dirent) eq 'GlusterFS::GFAPI::FFI::DirEntry'
    , 'GlusterFS::GFAPI::FFI::DirEntry - new()');
ok(defined($file) && ref($file) eq 'GlusterFS::GFAPI::FFI::File'
    , 'GlusterFS::GFAPI::FFI::File     - new()');

done_testing();
