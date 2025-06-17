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

if [[ "$#" != 1 ]]; then
    echo "ERROR! There should be 'runtime' or 'dev' parameter passed as argument.".
    exit 1
fi

if [[ "${1}" == "runtime" ]]; then
    INSTALLATION_TYPE="RUNTIME"
elif   [[ "${1}" == "dev" ]]; then
    INSTALLATION_TYPE="dev"
else
    echo "ERROR! Wrong argument. Passed ${1} and it should be one of 'runtime' or 'dev'.".
    exit 1
fi

function get_dev_dnf_deps() {
    echo "Getting dev dnf deps,${DEV_DNF_DEPS:-}"
    if [[ "${DEV_DNF_DEPS:-}" == "" ]]; then
        DEV_DNF_DEPS="\
            gcc gcc-c++ make which \
            python3-devel \
            git \
            graphviz graphviz-devel \
            krb5-devel \
            openldap-devel \
            cyrus-sasl-devel cyrus-sasl-lib \
            libffi-devel \
            openssl-devel \
            freetds freetds-devel \
            leveldb-devel \
            sqlite sqlite-devel \
            unixODBC unixODBC-devel \
            rsync \
            sudo \
            curl \
            pkgconfig \
            shadow-utils \
            zlib-devel \
            libxmlsec1 libxmlsec1-devel \
            net-tools \
            ncurses-compat-libs \
            passwd \
            tar \
            gzip \
            bzip2 \
            findutils \
            diffutils \
            util-linux \
            iproute \
            hostname \
            procps-ng \
            redhat-lsb-core \
            dumb-init"
        export DEV_DNF_DEPS
    fi
}

function get_runtime_dnf_deps() {
    if [[ "${RUNTIME_DNF_DEPS:-}" == "" ]]; then
        RUNTIME_DNF_DEPS="\
            python3 \
            python3-pip \
            which \
            freetds \
            krb5-libs \
            openldap \
            cyrus-sasl-lib \
            libffi \
            openssl \
            sqlite \
            unixODBC \
            rsync \
            sudo \
            curl \
            shadow-utils \
            zlib \
            libxmlsec1 \
            net-tools \
            ncurses-compat-libs \
            passwd \
            tar \
            gzip \
            bzip2 \
            findutils \
            diffutils \
            util-linux \
            iproute \
            hostname \
            procps-ng \
            redhat-lsb-core \
            dumb-init"
        export RUNTIME_DNF_DEPS
    fi
}

function install_docker_cli() {
    dnf install -y dnf-plugins-core device-mapper-persistent-data lvm2
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y docker-ce-cli
    dnf clean all
}

function install_amazonlinux_dev_dependencies() {
    dnf makecache
    dnf groupinstall -y "Development Tools"
    dnf install -y ${DEV_DNF_DEPS} ${ADDITIONAL_DEV_DNF_DEPS:-}
    dnf clean all
}

function install_amazonlinux_runtime_dependencies() {
    dnf makecache
    dnf install -y ${RUNTIME_DNF_DEPS} ${ADDITIONAL_RUNTIME_DNF_DEPS:-}
    dnf clean all
}

if [[ "${INSTALLATION_TYPE}" == "RUNTIME" ]]; then
    get_runtime_dnf_deps
    install_amazonlinux_runtime_dependencies
    install_docker_cli
else
    # get_dev_dnf_deps
    install_amazonlinux_dev_dependencies
    install_docker_cli
fi
