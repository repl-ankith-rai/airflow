#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# shellcheck shell=bash
set -euo pipefail

function get_dev_deps() {
    if [[ "${DEV_DEPS=}" == "" ]]; then
        DEV_DEPS="gcc gcc-c++ git graphviz graphviz-devel krb5-workstation openldap-clients \
        libev-devel libffi-devel geos-devel krb5-devel openldap-devel sqlite sqlite-devel \
        cyrus-sasl cyrus-sasl-devel cyrus-sasl-plain openssl-devel libxml2-devel libxslt-devel \
        python3-devel python3-pip dnf-plugins-core"
        export DEV_DEPS
    fi
}

function get_runtime_deps() {
    if [[ "${RUNTIME_DEPS=}" == "" ]]; then
        RUNTIME_DEPS="cyrus-sasl cyrus-sasl-plain krb5-workstation libev openldap-clients \
        geos-devel openldap graphviz libxml2 libxslt sqlite python3-selinux rsync \
        python3-pip dnf-plugins-core"
        export RUNTIME_DEPS
    fi
}

function install_docker_cli() {
    dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    dnf -y install docker-ce-cli
}

function install_dev_dependencies() {
    dnf update -y
    dnf install -y epel-release
    dnf install -y ${DEV_DEPS} ${ADDITIONAL_DEV_DEPS:-}
    # Install dumb-init directly since it's not in repos
    curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
    chmod +x /usr/local/bin/dumb-init
    dnf clean all
    rm -rf /var/cache/dnf/*
}

function install_runtime_dependencies() {
    dnf update -y
    dnf install -y epel-release
    dnf install -y ${RUNTIME_DEPS} ${ADDITIONAL_RUNTIME_DEPS:-}
    # Install dumb-init directly since it's not in repos
    curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
    chmod +x /usr/local/bin/dumb-init
    dnf clean all
    rm -rf /var/cache/dnf/*
}

if [[ "$#" != 1 ]]; then
    echo "ERROR! There should be 'runtime' or 'dev' parameter passed as argument."
    exit 1
fi

if [[ "${1}" == "runtime" ]]; then
    INSTALLATION_TYPE="RUNTIME"
elif [[ "${1}" == "dev" ]]; then
    INSTALLATION_TYPE="dev"
else
    echo "ERROR! Wrong argument. Passed ${1} and it should be one of 'runtime' or 'dev'."
    exit 1
fi

if [[ "${INSTALLATION_TYPE}" == "RUNTIME" ]]; then
    get_runtime_deps
    install_runtime_dependencies
    install_docker_cli
else
    get_dev_deps
    install_dev_dependencies
    install_docker_cli
fi
