ARTIFACT_ID=k8s-longhorn
VERSION=1.5.1-2
MAKEFILES_VERSION=9.0.0

include build/make/variables.mk
include build/make/clean.mk
include build/make/self-update.mk

##@ Release

IMAGE_IMPORT_TARGET=
COMPONENT_DEPLOY_NAMESPACE=longhorn-system
CHECK_VAR_TARGETS=check-all-vars-without-image
include build/make/k8s-component.mk

.PHONY: longhorn-release
longhorn-release: ## Interactively starts the release workflow.
	@echo "Starting git flow release..."
	@build/make/release.sh longhorn
