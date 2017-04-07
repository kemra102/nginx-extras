FROM centos:7
MAINTAINER kemra102

RUN yum -y groupinstall 'Development Tools'
RUN yum -y install epel-release
RUN yum -y install openssl-devel pcre-devel zlib-devel jq rpm-build
