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

function install_dumb_init() {
    # Install dumb-init with architecture detection
    local arch
    arch=$(uname -m)
    local dumb_init_version="1.2.5"
    local dumb_init_url="https://github.com/Yelp/dumb-init/releases/download/v${dumb_init_version}/dumb-init_${dumb_init_version}_${arch}"

    # Map architectures to dumb-init naming
    if [[ "${arch}" == "x86_64" ]]; then
        dumb_init_url="https://github.com/Yelp/dumb-init/releases/download/v${dumb_init_version}/dumb-init_${dumb_init_version}_amd64"
    elif [[ "${arch}" == "aarch64" ]]; then
        dumb_init_url="https://github.com/Yelp/dumb-init/releases/download/v${dumb_init_version}/dumb-init_${dumb_init_version}_arm64"
    fi

    echo "Installing dumb-init v${dumb_init_version} from ${dumb_init_url}"
    curl -L -o /usr/local/bin/dumb-init "${dumb_init_url}"
    chmod +x /usr/local/bin/dumb-init
}

function install_dev_dependencies() {
    dnf update -y
    dnf install -y epel-release
    dnf install -y ${DEV_DEPS} ${ADDITIONAL_DEV_DEPS:-}
    install_dumb_init
    dnf clean all
    rm -rf /var/cache/dnf/*
}

function install_runtime_dependencies() {
    dnf update -y
    dnf install -y epel-release
    dnf install -y ${RUNTIME_DEPS} ${ADDITIONAL_RUNTIME_DEPS:-}
    install_dumb_init
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

echo "Installing dependencies for Amazon Linux 2023 FIPS-compliant environment"

if [[ "${INSTALLATION_TYPE}" == "RUNTIME" ]]; then
    get_runtime_deps
    install_runtime_dependencies
    install_docker_cli
else
    get_dev_deps
    install_dev_dependencies
    install_docker_cli
fi
