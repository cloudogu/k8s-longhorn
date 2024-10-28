ARTIFACT_ID=k8s-longhorn
VERSION=1.5.1-5
MAKEFILES_VERSION=9.3.2

include build/make/variables.mk
include build/make/clean.mk
include build/make/self-update.mk

##@ Release

COMPONENT_DEPLOY_NAMESPACE=longhorn-system
include build/make/k8s-component.mk

.PHONY: longhorn-release
longhorn-release: ## Interactively starts the release workflow.
	@echo "Starting git flow release..."
	@build/make/release.sh longhorn
