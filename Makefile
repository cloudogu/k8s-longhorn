ARTIFACT_ID=k8s-longhorn
VERSION=1.3.1-4
MAKEFILES_VERSION=7.0.1

include build/make/variables.mk
include build/make/k8s.mk
include build/make/clean.mk

##@ Release

.PHONY: generate-release-resource
generate-release-resource: $(K8S_RESOURCE_TEMP_FOLDER)
	@cp manifests/longhorn.yaml ${K8S_RESOURCE_TEMP_YAML}


.PHONY: longhorn-release
longhorn-release: ## Interactively starts the release workflow.
	@echo "Starting git flow release..."
	@build/make/release.sh longhorn