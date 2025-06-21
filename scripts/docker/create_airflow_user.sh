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

# This script creates the airflow user and directories with proper permissions
# It's extracted as a separate script to avoid duplication in the Dockerfile

set -euo pipefail

: "${AIRFLOW_USER_HOME_DIR:?AIRFLOW_USER_HOME_DIR must be set}"
: "${AIRFLOW_HOME:?AIRFLOW_HOME must be set}"
: "${AIRFLOW_UID:?AIRFLOW_UID must be set}"

# Create AIRFLOW_USER_HOME_DIR first
mkdir -p "${AIRFLOW_USER_HOME_DIR}"

# Use userdel first to ensure clean state
userdel -r airflow 2>/dev/null || true

# Use useradd for Amazon Linux 2023 compatibility 
useradd --uid "${AIRFLOW_UID}" \
        --home "${AIRFLOW_USER_HOME_DIR}" \
        --shell /bin/bash \
        --system \
        --create-home \
        airflow

mkdir -pv "${AIRFLOW_HOME}"
mkdir -pv "${AIRFLOW_HOME}/dags"
mkdir -pv "${AIRFLOW_HOME}/logs"

chown -R airflow:0 "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}"
chmod -R g+rw "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}"
find "${AIRFLOW_HOME}" -executable ! -type l -print0 | xargs --null chmod g+x