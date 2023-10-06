ARTIFACT_ID=k8s-longhorn
VERSION=1.5.1-2
MAKEFILES_VERSION=8.7.0

include build/make/variables.mk
include build/make/clean.mk
include build/make/self-update.mk

##@ Release

PRE_APPLY_TARGETS=
K8S_PRE_GENERATE_TARGETS=generate-release-resource
COMPONENT_DEPLOY_NAMESPACE=longhorn-system
include build/make/k8s-component.mk

.PHONY: generate-release-resource
generate-release-resource: $(K8S_RESOURCE_TEMP_FOLDER)
	@cp manifests/dummy.yaml ${K8S_RESOURCE_TEMP_YAML}

.PHONY: longhorn-release
longhorn-release: ## Interactively starts the release workflow.
	@echo "Starting git flow release..."
	@build/make/release.sh longhorn

HELM_TEMPLATE_DIR=$(K8S_RESOURCE_TEMP_FOLDER)/helm/templates
