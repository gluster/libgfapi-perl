%define perl_vendorlib    %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch   %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)
%global perl_package_name libgfapi-perl

Name:           perl-glusterfs-api
Summary:        Perl bindings for GlusterFS libgfapi
Version:        0.4
Release:        1%{?dist}
License:        GPLv2 or LGPLv3+
Group:          System Environment/Libraries
Vendor:         Gluster Community
URL:            https://github.com/gluster/libgfapi-perl
Source0:        %{perl_package_name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       perl(overload)
Requires:       perl(Fcntl)
Requires:       perl(POSIX)
Requires:       perl(Carp)
Requires:       perl(Try::Tiny)
Requires:       perl(File::Spec)
Requires:       perl(List::MoreUtils)
Requires:       perl(Moo)
Requires:       perl(Generator::Object)
Requires:       perl(FFI::Platypus)
Requires:       perl(FFI::CheckLib)
Requires:       glusterfs-api >= 3.7.0
BuildRequires:  perl-ExtUtils-MakeMaker

%description
libgfapi is a library that allows applications to natively access GlusterFS
volumes. This package contains perl bindings to libgfapi.

%prep
%setup -T -D -n %{perl_package_name}-%{version}
chmod -R u+w %{_builddir}/%{perl_package_name}-%{version}

if [ -f pm_to_blib ]; then rm -f pm_to_blib; fi

%build
%{__perl} Makefile.PL OPTIMIZE="$RPM_OPT_FLAGS" INSTALLDIRS=vendor VENDORPREFIX=/usr INSTALLVENDORARCH=/usr/share/perl5/vendor_perl INSTALLVENDORLIB=/usr/share/perl5/vendor_perl INSTALLVENDORBIN=/usr/bin INSTALLVENDORSCRIPT=/usr/bin INSTALLVENDORMAN1DIR=/usr/share/man/man1 INSTALLVENDORMAN3DIR=/usr/share/man/man3 INSTALLSCRIPT=/usr/bin
%{__make} %{?_smp_mflags}

if [ -z "$RPMBUILD_NOTESTS" ]; then
   make test
fi

%install
%{__rm} -rf %{buildroot}
%{__make} install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name '*.bs' -size 0 -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;
%{_fixperms} $RPM_BUILD_ROOT/*

# Clean up buildroot
find %{buildroot} -name .packlist -exec %{__rm} {} \;

# Remove manfiles (conflicts with perl package)
%{__rm} -rf %{buildroot}/%{_mandir}/man3

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, -)
%doc Changes MAINTAINERS VERSION README.md

%if ( 0%{?rhel} > 6 )
%license COPYING-GPLV2 COPYING-LGPLV3
%else
%doc COPYING-GPLV2 COPYING-LGPLV3
%endif

%{perl_vendorlib}/GlusterFS/*

%changelog
* Fri Feb 09 2018 Ji-Hyeon Gim <potatogim@gluesys.com> - 0.3-1
- Introducing spec file.
