# Copyright 2024 Wong Hoi Sing Edison <hswong3i@pantarei-design.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

%global debug_package %{nil}

%global source_date_epoch_from_changelog 0

Name: python-podman
Epoch: 100
Version: 4.8.2
Release: 1%{?dist}
BuildArch: noarch
Summary: Bindings for Podman RESTful API
License: Apache-2.0
URL: https://github.com/containers/podman-py/tags
Source0: %{name}_%{version}.orig.tar.gz
BuildRequires: fdupes
BuildRequires: python-rpm-macros
BuildRequires: python3-devel
BuildRequires: python3-setuptools

%description
This python package is a library of bindings to use the RESTful API of
Podman.

%prep
%autosetup -T -c -n %{name}_%{version}-%{release}
tar -zx -f %{S:0} --strip-components=1 -C .

%build
%py3_build

%install
%py3_install
find %{buildroot}%{python3_sitelib} -type f -name '*.pyc' -exec rm -rf {} \;
fdupes -qnrps %{buildroot}%{python3_sitelib}

%check

%if 0%{?suse_version} > 1500
%package -n python%{python3_version_nodots}-podman
Summary: Bindings for Podman RESTful API
Requires: python3
Requires: python3-pyxdg >= 0.26
Requires: python3-requests >= 2.24
Requires: python3-rich >= 12.5.1
Requires: python3-tomli >= 1.2.3
Requires: python3-urllib3
Provides: python3-podman = %{epoch}:%{version}-%{release}
Provides: python3dist(podman) = %{epoch}:%{version}-%{release}
Provides: python%{python3_version}-podman = %{epoch}:%{version}-%{release}
Provides: python%{python3_version}dist(podman) = %{epoch}:%{version}-%{release}
Provides: python%{python3_version_nodots}-podman = %{epoch}:%{version}-%{release}
Provides: python%{python3_version_nodots}dist(podman) = %{epoch}:%{version}-%{release}

%description -n python%{python3_version_nodots}-podman
This python package is a library of bindings to use the RESTful API of
Podman.

%files -n python%{python3_version_nodots}-podman
%license LICENSE
%{python3_sitelib}/*
%endif

%if !(0%{?suse_version} > 1500)
%package -n python3-podman
Summary: Bindings for Podman RESTful API
Requires: python3
Requires: python3-pyxdg >= 0.26
Requires: python3-requests >= 2.24
Requires: python3-rich >= 12.5.1
Requires: python3-tomli >= 1.2.3
Requires: python3-urllib3
Provides: python3-podman = %{epoch}:%{version}-%{release}
Provides: python3dist(podman) = %{epoch}:%{version}-%{release}
Provides: python%{python3_version}-podman = %{epoch}:%{version}-%{release}
Provides: python%{python3_version}dist(podman) = %{epoch}:%{version}-%{release}
Provides: python%{python3_version_nodots}-podman = %{epoch}:%{version}-%{release}
Provides: python%{python3_version_nodots}dist(podman) = %{epoch}:%{version}-%{release}

%description -n python3-podman
This python package is a library of bindings to use the RESTful API of
Podman.

%files -n python3-podman
%license LICENSE
%{python3_sitelib}/*
%endif

%changelog
