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
# shellcheck source=scripts/docker/common.sh
. "$( dirname "${BASH_SOURCE[0]}" )/common.sh"

set -euo pipefail

common::get_colors
declare -a packages

# https://dev.mysql.com/blog-archive/introducing-mysql-innovation-and-long-term-support-lts-versions/
readonly MYSQL_LTS_VERSION="8.0"
# https://mariadb.org/about/#maintenance-policy
readonly MARIADB_LTS_VERSION="10.11"

: "${INSTALL_MYSQL_CLIENT:?Should be true or false}"
: "${INSTALL_MYSQL_CLIENT_TYPE:-mariadb}"

install_mysql_client() {
    if [[ "${1}" == "dev" ]]; then
        packages=("mysql" "mysql-devel")
    elif [[ "${1}" == "prod" ]]; then
        packages=("mysql")
    else
        echo
        echo "${COLOR_RED}Specify either prod or dev${COLOR_RESET}"
        echo
        exit 1
    fi
    echo
    echo "${COLOR_BLUE}Installing Oracle MySQL client version ${MYSQL_LTS_VERSION}: ${1}${COLOR_RESET}"
    echo
    dnf install -y "${packages[@]}"
    dnf clean all
}

install_mariadb_client() {
    if [[ "${1}" == "dev" ]]; then
        packages=("mariadb" "mariadb-devel")
    elif [[ "${1}" == "prod" ]]; then
        packages=("mariadb")
    else
        echo
        echo "${COLOR_RED}Specify either prod or dev${COLOR_RESET}"
        echo
        exit 1
    fi
    echo
    echo "${COLOR_BLUE}Installing MariaDB client version ${MARIADB_LTS_VERSION}: ${1}${COLOR_RESET}"
    echo "${COLOR_YELLOW}MariaDB client protocol-compatible with MySQL client.${COLOR_RESET}"
    echo
    dnf install -y "${packages[@]}"
    dnf clean all
}

# Install MySQL client only if it is not disabled.
# INSTALL_MYSQL_CLIENT_TYPE=mysql : Install MySQL client from Oracle repository.
# INSTALL_MYSQL_CLIENT_TYPE=mariadb : Install MariaDB client from MariaDB repository.
# https://mariadb.com/kb/en/mariadb-clientserver-tcp-protocol/
# For ARM64 INSTALL_MYSQL_CLIENT_TYPE ignored and always install MariaDB.
if [[ ${INSTALL_MYSQL_CLIENT:="true"} == "true" ]]; then
    if [[ $(uname -m) == "arm64" || $(uname -m) == "aarch64" ]]; then
        INSTALL_MYSQL_CLIENT_TYPE="mariadb"
        echo
        echo "${COLOR_YELLOW}Client forced to mariadb for ARM${COLOR_RESET}"
        echo
    fi

    if [[ "${INSTALL_MYSQL_CLIENT_TYPE}" == "mysql" ]]; then
        install_mysql_client "${@}"
    elif [[ "${INSTALL_MYSQL_CLIENT_TYPE}" == "mariadb" ]]; then
        install_mariadb_client "${@}"
    else
        echo
        echo "${COLOR_RED}Specify either mysql or mariadb, got ${INSTALL_MYSQL_CLIENT_TYPE}${COLOR_RESET}"
        echo
        exit 1
    fi
fi
