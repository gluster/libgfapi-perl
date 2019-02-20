package GlusterFS::GFAPI::FFI::Util;

BEGIN
{
    our $AUTHOR  = 'cpan:potatogim';
    our $VERSION = '0.4';
}

use strict;
use warnings;
use utf8;

use FFI::Platypus;
use Carp;
use Sub::Exporter
        -setup =>
        {
            exports => [qw/libgfapi_soname/],
        };

sub libgfapi_soname
{
    my %args = @_;

    my $ffi = FFI::Platypus->new()->find_lib(lib => 'gfapi');
    my $lib = $ffi->{lib};

    if (!defined($lib) || @{$lib} == 0)
    {
        croak("Could not find libgfapi");
    }

    return $lib;
}

1;

__END__

=encoding utf8

=head1 NAME

GlusterFS::GFAPI::FFI::Util - GlusterFS::GFAPI::FFI convenience functions

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=head1 AUTHOR

Ji-Hyeon Gim E<lt>potatogim@gluesys.comE<gt>

=head2 CONTRIBUTORS

=over

=item Tae-Hwa Lee E<lt>alghost.lee@gmail.comE<gt>

=item Hyo-Chan Lee E<lt>hyochan.lee@gmail.comE<gt>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright 2017-2019 by Ji-Hyeon Gim.

This is free software; you can redistribute it and/or modify it under the same terms as the GPLv2/LGPLv3.

=cut

