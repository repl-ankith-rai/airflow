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

: "${INSTALL_MYSQL_CLIENT:?Should be true or false}"
: "${INSTALL_MYSQL_CLIENT_TYPE:-mariadb}"

install_mysql_client() {
    if [[ "${1}" == "dev" ]]; then
        packages=("mysql-devel" "mysql")
    elif [[ "${1}" == "prod" ]]; then
        packages=("mysql")
    else
        echo
        echo "${COLOR_RED}Specify either prod or dev${COLOR_RESET}"
        echo
        exit 1
    fi

    echo
    echo "${COLOR_BLUE}Installing MySQL Community client${COLOR_RESET}"
    echo

    # Add MySQL repository
    dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
    dnf config-manager --enable mysql80-community
    dnf install -y ${packages[@]}
    dnf clean all
    rm -rf /var/cache/dnf/*
}

install_mariadb_client() {
    if [[ "${1}" == "dev" ]]; then
        packages=("mariadb-devel" "mariadb")
    elif [[ "${1}" == "prod" ]]; then
        packages=("mariadb-connector-c" "mariadb")
    else
        echo
        echo "${COLOR_RED}Specify either prod or dev${COLOR_RESET}"
        echo
        exit 1
    fi

    echo
    echo "${COLOR_BLUE}Installing MariaDB client${COLOR_RESET}"
    echo "${COLOR_YELLOW}MariaDB client protocol-compatible with MySQL client.${COLOR_RESET}"
    echo

    # Install MariaDB from default repo
    dnf install -y ${packages[@]}
    dnf clean all
    rm -rf /var/cache/dnf/*
}

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
