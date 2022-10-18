# ==============================================================================
# Welcome to the Makefile
# ==============================================================================
#
# This Makefile contains a series of tasks which can help with building, testing
# and working with the app. The following tasks are available to you:
#
# Image building & releasing actions:
#
#   make docker-build      - Builds a production Docker image.
#   make docker-image      - Builds a production Docker image and tags it as
#                            appropriate based on the current branch & tag.
#   make docker-release    - Builds a production Docker image and uploads to the
#                            registry.
#

# ==============================================================================
# Configuration
# ==============================================================================

DOCKER_IMAGE := 202367502124.dkr.ecr.eu-west-2.amazonaws.com/muck
DOCKER_BUILD_CMD = docker build $(DOCKER_BUILD_ARGS) .

# ==============================================================================
# Main Targets
# ==============================================================================

# image ID within the targets by running the build again with the -q option. The
# second run with the -q option will be very fast thanks to layer caching.
.PHONY: docker-build
docker-build:
	$(DOCKER_BUILD_CMD)

# ==============================================================================
# Release
# ==============================================================================

DOCKER_TAG_NAME ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
DOCKER_TAG_VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null)

ifeq ($(DOCKER_TAG_NAME),master)
	DOCKER_TAG_NAME = latest
endif
ifeq ($(DOCKER_TAG_NAME),main)
	DOCKER_TAG_NAME = latest
endif

.PHONY: docker-image
docker-image: docker-build
	$(eval IMAGE := $(shell $(DOCKER_BUILD_CMD) -q))
ifeq ($(DOCKER_TAG_NAME),latest)
	docker tag "$(IMAGE)" "$(DOCKER_IMAGE):$(DOCKER_TAG_NAME)"
endif

.PHONY: docker-release
docker-release: docker-image
ifeq ($(DOCKER_TAG_NAME),latest)
	docker push "$(DOCKER_IMAGE):$(DOCKER_TAG_NAME)"
endif
ifneq ($(DOCKER_TAG_VERSION),)
	docker tag "$(DOCKER_IMAGE):$(DOCKER_TAG_NAME)" \
		"$(DOCKER_IMAGE):$(DOCKER_TAG_VERSION)" && \
		docker push "$(DOCKER_IMAGE):$(DOCKER_TAG_VERSION)"
endif
