docker buildx build --builder airflow_cache --build-arg AIRFLOW_CONSTRAINTS=constraints-no-providers --build-arg PYTHON_BASE_IMAGE=434423891815.dkr.ecr.us-east-1.amazonaws.com/machine-images/fips-base:m-16389-amazon-linux-2023-nodejs --build-arg AIRFLOW_VERSION=2.11.0 --build-arg INCLUDE_PRE_RELEASE=false --build-arg INSTALL_DISTRIBUTIONS_FROM_CONTEXT=false --build-arg DOCKER_CONTEXT_FILES=./docker-context-files --build-arg COMMIT_SHA=1260d4c5fb415aa43d025daf26bd4c81918b9294 --platform linux/amd64 --output type=docker  -t apache/airflow:2.11.0-local-fips1 .


docker buildx build --builder airflow_cache --build-arg AIRFLOW_CONSTRAINTS=constraints-no-providers --build-arg PYTHON_BASE_IMAGE=amazonlinux:2023 --build-arg AIRFLOW_VERSION=2.11.0 --build-arg INCLUDE_PRE_RELEASE=false --build-arg INSTALL_DISTRIBUTIONS_FROM_CONTEXT=false --build-arg DOCKER_CONTEXT_FILES=./docker-context-files --build-arg COMMIT_SHA=1260d4c5fb415aa43d025daf26bd4c81918b9294 --platform linux/amd64 --output type=docker  -t apache/airflow:2.11.0-local-fips1 .


docker buildx build \
  --builder airflow_cache \
  --no-cache \
  --build-arg AIRFLOW_CONSTRAINTS=constraints-no-providers \
  --build-arg PYTHON_BASE_IMAGE=amazonlinux:2023 \
  --build-arg AIRFLOW_VERSION=2.11.0 \
  --build-arg INCLUDE_PRE_RELEASE=false \
  --build-arg INSTALL_DISTRIBUTIONS_FROM_CONTEXT=false \
  --build-arg DOCKER_CONTEXT_FILES=./docker-context-files \
  --build-arg COMMIT_SHA=1260d4c5fb415aa43d025daf26bd4c81918b9294 \
  --platform linux/amd64 \
  --output type=docker \
  -t apache/airflow:2.11.0-local-fips1 \
  .