use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'GlusterFS::GFAPI::FFI',
    DISTNAME           => 'GlusterFS-GFAPI-FFI',
    AUTHOR             => 'Ji-Hyeon Gim <potatogim@potatogim.net>',
    VERSION_FROM       => 'lib/GlusterFS/GFAPI/FFI.pm',
    ABSTRACT_FROM      => 'lib/GlusterFS/GFAPI/FFI.pm',
    LICENSE            => 'perl',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
        'FFI::CheckLib'       => 0,
        'FFI::Platypus'       => 0,
    },
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    PREREQ_PM => {
        'Carp'                  => 0,
        'FFI::Platypus'         => 0,
        'FFI::Platypus::Buffer' => 0,
        'FFI::Platypus::Memory' => 0,
        'Try::Tiny'             => 0,
        'strict'                => 0,
        'warnings'              => 0,
        'threads'               => 0,
    },
    TEST_REQUIRES => {
        'Symbol'          => 0,
        'IPC::Open3'      => 0,
        'IO::Select'      => 0,
        'List::Util'      => 0,
        'POSIX'           => 0,
        'Scalar::Util'    => 0,
        'locale'          => 0,
        'utf8'            => 0,
        'Data::Dumper'    => 0,
        'Devel::Peek'     => 0,
        'Time::HiRes'     => 0,
        'Test::Deep'      => 0,
        'Test::More'      => 0,
        'Test::Exception' => 0.43,
    },
    EXE_FILES => [],
    dist => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    clean => {
        FILES => 'GlusterFS-GFAPI-FFI-*',
    },
    test => {
        TESTS => 't/*.t',
    },
    (
        eval { ExtUtils::MakeMaker->VERSION(6.46) }
            ? (
                META_MERGE => {
                    'meta-spec' => { version => 2 },
                    resources   => {
                        type => 'git',
                        url  => 'https://github.com/potatogim/libgfapi-perl.git',
                        web  => 'https://github.com/potatogim/libgfapi-perl',
                    },
                })
            : ()
    ),
);
