
# syntax=docker/dockerfile:1.3
FROM ubuntu:20.04
ENV DOCKER_BUILDKIT=1


ENV DEBIAN_FRONTEND=noninteractive \
    PIP_CACHE_DIR=/.cache \
    DJANGO_SETTINGS_MODULE=core.settings.label_studio \
    LABEL_STUDIO_BASE_DATA_DIR=/label-studio/data \
    SETUPTOOLS_USE_DISTUTILS=stdlib

WORKDIR /label-studio

# install packages
RUN set -eux; \
    apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential postgresql-client libmysqlclient-dev mysql-client python3.8 python3-pip python3.8-dev \
    uwsgi git libxml2-dev libxslt-dev zlib1g-dev

# Copy and install middleware dependencies
COPY deploy/requirements-mw.txt /label-studio
RUN --mount=type=cache,target=$PIP_CACHE_DIR \
    pip3 install -r requirements-mw.txt

# Copy and install requirements.txt first for caching
COPY deploy/requirements.txt /label-studio
RUN --mount=type=cache,target=$PIP_CACHE_DIR \
    pip3 install -r requirements.txt

COPY . /label-studio
RUN --mount=type=cache,target=$PIP_CACHE_DIR \
    pip3 install -e .

COPY . /label-studio
RUN --mount=type=cache,target=$PIP_CACHE_DIR \
    pip3 install psycopg2-binary

EXPOSE 8080
RUN ./deploy/prebuild_wo_frontend.sh

ENV DATABASE_URL='postgres://pksvgoiqkjgvcn:80623705d21055580390fb6fd93ab1bf8171f64d85a39838a4fa75d63e8b1395@ec2-176-34-105-15.eu-west-1.compute.amazonaws.com:5432/d8krgibv3b63l3'



# ['localhost','127.0.0.1','traffic-africa-annotator.herokuapp.com']


ENTRYPOINT ["./deploy/docker-entrypoint.sh"]
CMD ["label-studio"]