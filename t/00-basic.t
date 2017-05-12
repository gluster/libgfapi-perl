#/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test::Most;

diag('00-basic.t');

use_ok('GlusterFS::GFAPI::FFI');
use_ok('GlusterFS::GFAPI::FFI::Volume');
use_ok('GlusterFS::GFAPI::FFI::Dir');
use_ok('GlusterFS::GFAPI::FFI::File');

my $vol  = GlusterFS::GFAPI::FFI::Volume->new();
my $dir  = GlusterFS::GFAPI::FFI::Dir->new();
my $file = GlusterFS::GFAPI::FFI::File->new();

ok(defined($vol),  'GlusterFS::GFAPI::FFI::Volume - new()');
ok(defined($dir),  'GlusterFS::GFAPI::FFI::Dir    - new()');
ok(defined($file), 'GlusterFS::GFAPI::FFI::File   - new()');

done_testing();
