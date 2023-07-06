ARTIFACT_ID=k8s-longhorn
VERSION=1.4.1-1
MAKEFILES_VERSION=7.9.0

include build/make/variables.mk
include build/make/clean.mk
include build/make/self-update.mk

##@ Release

K8S_PRE_GENERATE_TARGETS=generate-release-resource
include build/make/k8s.mk

.PHONY: generate-release-resource
generate-release-resource: $(K8S_RESOURCE_TEMP_FOLDER)
	@cp manifests/longhorn.yaml ${K8S_RESOURCE_TEMP_YAML}


.PHONY: longhorn-release
longhorn-release: ## Interactively starts the release workflow.
	@echo "Starting git flow release..."
	@build/make/release.sh longhorn


# These targets wrap the helm targets because helmify always adds the project name as prefix to all resources.
# This behaviour leads to wrong resource names because the original resource names do not start with the project name prefix.
HELM_TEMPLATE_DIR=$(K8S_RESOURCE_TEMP_FOLDER)/helm/templates

.PHONY: longhorn-k8s-helm-generate
longhorn-k8s-helm-generate: k8s-helm-generate fix-service-errors change-helm-prefix

ENGINE_MANAGER_SERVICE="${HELM_TEMPLATE_DIR}/engine-manager.yaml"
REPLICA_MANAGER_SERVICE="${HELM_TEMPLATE_DIR}/replica-manager.yaml"

.PHONY: fix-service-errors
fix-service-errors:
	@echo "Fix wrong service type creation"
	@sed -i 's/type: {{ .Values.engineManager.type }}/clusterIP: None/' "${ENGINE_MANAGER_SERVICE}"
	@sed -i 's/	{{- .Values.engineManager.ports | toYaml | nindent 2 -}}//' "${ENGINE_MANAGER_SERVICE}"
	@sed -i 's/  ports://' "${ENGINE_MANAGER_SERVICE}"
	@sed -i 's/type: {{ .Values.engineManager.type }}/clusterIP: None/' "${REPLICA_MANAGER_SERVICE}"
	@sed -i 's/	{{- .Values.replicaManager.ports | toYaml | nindent 2 -}}//' "${REPLICA_MANAGER_SERVICE}"
	@sed -i 's/  ports://' "${REPLICA_MANAGER_SERVICE}"

.PHONY: change-helm-prefix
change-helm-prefix:
	@echo "Replacing generated Helm resource names with previous values"
	@for file in "${HELM_TEMPLATE_DIR}"/*.yaml ; do \
    	    sed -i 's/{{ include "helm.fullname" . }}/longhorn/' $${file}; \
    done

.PHONY: longhorn-k8s-helm-apply
longhorn-k8s-helm-apply: longhorn-k8s-helm-generate ## Generates and installs the helm chart.
	@echo "Apply generated helm chart"
	@${BINARY_HELM} upgrade -i ${ARTIFACT_ID} ${K8S_HELM_TARGET}

.PHONY: longhorn-k8s-helm-package-release
longhorn-k8s-helm-package-release: longhorn-k8s-helm-generate ## Generates and packages the helm chart with release urls.
	@echo "Package generated helm chart"
	@${BINARY_HELM} package ${K8S_HELM_TARGET} -d ${K8S_HELM_TARGET}
