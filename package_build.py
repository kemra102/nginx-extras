#!/usr/bin/env python

import json
import os
import requests
import shutil
from subprocess import call
import sys
import tarfile

with open('config.json') as data_file:
    data = json.load(data_file)

os.environ['MODULE_NAME'] = sys.argv[1].lower()
os.environ['MODULE_URL'] = data['modules'][os.environ['MODULE_NAME']]['source_url']
os.environ['MODULE_VERSION'] = data['modules'][os.environ['MODULE_NAME']]['version']
os.environ['NGINX_VERSION'] = data['nginx_version']
os.environ['SHARED_LIBRARY'] = data['modules'][os.environ['MODULE_NAME']]['library_name']

def buildModule(moduleName):
    os.chdir('build/nginx-' + os.environ['NGINX_VERSION'])
    call(['./configure', '--add-dynamic-module=../' + 'nginx-module-' + os.environ['MODULE_NAME'] + '-' + os.environ['MODULE_VERSION']])
    call('make')

def cleanBuildEnv():
    if os.path.exists('build'):
        shutil.rmtree('build')

def createBuildEnv():
    if not os.path.exists('build'):
        os.makedirs('build')

def getModuleSource(moduleName):
    createBuildEnv()
    request = requests.get(os.environ['MODULE_URL'] + 'v' + os.environ['MODULE_VERSION'] + '.tar.gz')
    with open('build/nginx-module-' + os.environ['MODULE_NAME'] + '-' + os.environ['MODULE_VERSION'] + '.tar.gz', 'w') as file:
        file.write(request.content)
        file.close

def getNGINXSource():
    createBuildEnv()
    filename = mainFileName()
    url = 'http://nginx.org/download/' + filename
    request = requests.get(url)
    with open('build/' + filename, 'w') as file:
        file.write(request.content)
        file.close

def mainFileName():
    return 'nginx-' + os.environ['NGINX_VERSION'] + '.tar.gz'

def unpackCode(fileName):
    tar = tarfile.open('build/' + fileName)
    tar.extractall(path='build/')
    tar.close()

def buildRPM():
    os.chdir('/src/build')
    for _, dir in enumerate(['BUILD', 'RPMS', 'SOURCES', 'SPECS', 'SRPMS']):
        os.makedirs(dir)
    shutil.copy('nginx-' + os.environ['NGINX_VERSION'] + '/objs/' + os.environ['SHARED_LIBRARY'], 'SOURCES')
    for _, source in enumerate(data['modules'][os.environ['MODULE_NAME']]['sources']):
        shutil.copy('nginx-module-' + os.environ['MODULE_NAME'] + '-' + os.environ['MODULE_VERSION'] + '/' + source, 'SOURCES')
    f = open('/root/.rpmmacros','w')
    f.write('%_topdir /src/build')
    f.close()
    shutil.copy('/src/spec/nginx-module-' + os.environ['MODULE_NAME'] + '.spec', '/src/build/SPECS')
    call(['rpmbuild', '-bb', 'SPECS/nginx-module-' + os.environ['MODULE_NAME'] + '.spec'])

cleanBuildEnv()
getNGINXSource()
unpackCode(mainFileName())
getModuleSource(os.environ['MODULE_NAME'])
unpackCode('nginx-module-' + os.environ['MODULE_NAME'] + '-' + os.environ['MODULE_VERSION'] + '.tar.gz')
buildModule(os.environ['MODULE_NAME'])
buildRPM()
