%if 0%{?rhel} == 6
  %define dist el6
%endif
%if 0%{?rhel} == 7
  %define dist el7
%endif
%define version %{getenv:MODULE_VERSION}

Summary: NGINX NAXSI (Nginx Anti XSS & SQL Injection) WAF
Name: nginx-module-naxsi
Version: %{?version}
Release: 1.%{?dist}.wso
License: BSD
Group: System Environment/Daemons
URL: https://github.com/nbs-system/naxsi

Source0: %{getenv:SHARED_LIBRARY}
Source1: LICENSE
Source2: README.md

BuildArch: x86_64
Requires: nginx

%description
NGINX NAXSI (Nginx Anti XSS & SQL Injection) WAF

%prep
cp -p %SOURCE0 .
cp -p %SOURCE1 .
cp -p %SOURCE2 .

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/etc/nginx/modules
install -m 755 %{getenv:SHARED_LIBRARY} %{buildroot}/etc/nginx/modules/

%files
%if 0%{?rhel} == 7
  %license LICENSE
%else
  %doc LICENSE README.md
%endif
%attr(0644, root, root) /etc/nginx/modules/%{getenv:SHARED_LIBRARY}
