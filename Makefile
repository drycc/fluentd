SHORT_NAME ?= fluentd
BUILD_TAG ?= git-$(shell git rev-parse --short HEAD)
DRYCC_REGISTRY ?= ${DEV_REGISTRY}
IMAGE_PREFIX ?= drycc
PLATFORM ?= linux/amd64,linux/arm64

include versioning.mk

build: docker-build
push: docker-push

docker-build:
	docker build ${DOCKER_BUILD_FLAGS} -t ${IMAGE} rootfs
	docker tag ${IMAGE} ${MUTABLE_IMAGE}

docker-buildx:
	docker buildx build --platform ${PLATFORM} ${DOCKER_BUILD_FLAGS} -t ${IMAGE} rootfs --push

test: docker-build
	docker run ${IMAGE} /bin/bash -c "cd /fluentd/drycc-output && rake test"

install:
	helm upgrade fluentd charts/fluentd --install --namespace drycc --set org=${IMAGE_PREFIX},image_tag=${VERSION}

upgrade:
	helm upgrade fluentd charts/fluentd --namespace drycc --set org=${IMAGE_PREFIX},image_tag=${VERSION}

uninstall:
	helm delete fluentd --purge
