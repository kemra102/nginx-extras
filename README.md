# NGINX Extras

This project is an effort to provide to the community access to dynamically built NGINX modules that they will be able to use with the latest stable release of NGINX.

This project is still in it's very early stages and there is still much to do:

- [x] Basic build script with docker build for CentOS 7.
- [ ] Add CentOS 6 Support.
- [ ] Update build script to push built RPMs to [Package Cloud](https://packagecloud.io/).
- [ ] Add a script/mechanism that can check for new versions of both NGINX & modules and rebuild if it finds a new version etc.
- [ ] Add more modules.


## How to Add a New Module

To add a new module as a potential build target you must update the `config.json` with the following values for that module (see existing modules for an example of the exact format):

* The name of the module.
* The name of the compiled shared library (`library_name`).
* The URL where downloads of the source code of the module are hosted (`source_url`).
* The files included in the source code download that should be included in the built RPM such as the README or the change log (`sources`).
* The version of the module (`version`).

## How to Build a Module

All builds should be done in Docker (currently this only supports CentOS 7). So first you'll need to build the docker image:

```bash
$ docker build .
```

One of the last things the command will do is give you the ID number of the built container. If that ID was `84617779f808` you can run the build like so (in this case for the `vts` module):

```bash
$ docker run -v $(pwd):/src 84617779f808 /src/package_build.sh vts
```

The created RPM will end up in `build/RPMS`.

## Example using vts
Inspect config.json for configs used.

# Build Module
```sh
@localhost˜  ~/src/nginx-extras git:(master) docker build .
Sending build context to Docker daemon 6.978 MB
Step 1/5 : FROM centos:7
 ---> 98d35105a391
 <snip>
 Complete!
 ---> 84617779f808
Removing intermediate container 9bf5b3adf6c9
Successfully built 84617779f808

@localhost  ~/src/nginx-extras git:(master) docker run -v $(pwd):/src 84617779f808 /src/package_build.sh vts
checking for OS
 + Linux 4.9.13-moby x86_64
checking for C compiler ... found
 + using GNU C compiler
 + gcc version: 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC)
 <snip>
 Wrote: /src/build/RPMS/x86_64/nginx-module-vts-0.1.14-1.el7.wso.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.QYRWoY
+ umask 022
+ cd /src/build/BUILD
+ /usr/bin/rm -rf /src/build/BUILDROOT/nginx-module-vts-0.1.14-1.el7.wso.x86_64
+ exit 0

@localhost  ~/src/nginx-extras git:(master) stat build/RPMS/x86_64/nginx-module-vts-0.1.14-1.el7.wso.x86_64.rpm
16777220 2509770 -rw-r--r-- 1 kemra102 localhost 0 242052 "Apr  7 13:48:03 2017" "Apr  7 13:48:03 2017" "Apr  7 13:48:03 2017" "Apr  7 13:48:03 2017" 4096 480 0 build/RPMS/x86_64/nginx-module-vts-0.1.14-1.el7.wso.x86_64.rpm
```

# Install / Use module
Install the version of nginx specified in config.json. In this example we are using the nginx repo.
```sh
yum -y -q install nginx-1.10.3-1.el7.ngx.x86_64
```

Install the module
```sh
rpm -ivh /vagrant/scripts/nginx-module-vts-0.1.14-1.el7.wso.x86_64.rpm
```

Tell nginx to use the module using the 'load_module' directive.
```sh
sed -i '1s;^;load_module "/usr/lib64/nginx/modules/ngx_http_vhost_traffic_status_module.so"\;\n;' /etc/nginx/nginx.conf
```

Then follow module specific setup steps.
For vts we need to setup /status & point to the module.

```sh
#example /etc/nginx/conf.d/localhost.conf
vhost_traffic_status_zone;

location /status {
          vhost_traffic_status_display;
          vhost_traffic_status_display_format html;
}
```
