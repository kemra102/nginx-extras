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
