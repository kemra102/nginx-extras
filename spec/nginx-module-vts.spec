%if 0%{?rhel} == 6
  %define dist .el6
%endif
%if 0%{?rhel} == 7
  %define dist .el7
  %define epoch 1
Epoch: %{epoch}
%endif
%define version %{getenv:MODULE_VERSION}

Summary: NGINX virtual host traffic status module.
Name: nginx-module-vts
Version: %{?version}
Release: 1%{?dist}.wso
License: BSD
Group: System Environment/Daemons
URL: https://github.com/vozlt/nginx-module-vts

Source0: %{getenv:SHARED_LIBRARY}
Source1: LICENSE
Source2: Changes
Source3: README.md

BuildArch: x86_64
Requires: nginx == %{?epoch:%{epoch}:}%{getenv:NGINX_VERSION}-1%{?dist}.ngx

%description
NGINX virtual host traffic status module.

%prep
cp -p %SOURCE0 .
cp -p %SOURCE1 .
cp -p %SOURCE2 .
cp -p %SOURCE3 .

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/etc/nginx/modules
install -m 755 %{getenv:SHARED_LIBRARY} %{buildroot}/etc/nginx/modules/

%files
%if 0%{?rhel} == 7
  %doc Changes README.md
  %license LICENSE
%else
  %doc Changes LICENSE README.md
%endif
%attr(0644, root, root) /etc/nginx/modules/%{getenv:SHARED_LIBRARY}
