#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

componentTemplateFile=k8s/helm/component-patch-tpl.yaml

# this function will be sourced from release.sh and be called from release_functions.sh
update_versions_modify_files() {
  echo "Update helm dependencies"
  make helm-update-dependencies  > /dev/null

  # Extract longhorn chart
  longhornVersion=$(yq '.dependencies[] | select(.name="longhorn").version' < "k8s/helm/Chart.yaml")
  longhornPackage="k8s/helm/charts/longhorn-${longhornVersion}.tgz"
  longhornTempChart="/tmp/longhorn"

  echo "Extract longhorn helm chart"
  tar -zxvf ${longhornPackage} -C "/tmp" > /dev/null

  longhornValues="${longhornTempChart}/values.yaml"

  echo "Set images in component path template"
  update_component_patch_template ".values.images.engine" ".image.longhorn.engine"
  update_component_patch_template ".values.images.manager" ".image.longhorn.manager"
  update_component_patch_template ".values.images.ui" ".image.longhorn.ui"
  update_component_patch_template ".values.images.instanceManager" ".image.longhorn.instanceManager"
  update_component_patch_template ".values.images.shareManager" ".image.longhorn.shareManager"
  update_component_patch_template ".values.images.backingImageManager" ".image.longhorn.backingImageManager"
  update_component_patch_template ".values.images.supportBundleKit" ".image.longhorn.supportBundleKit"
  update_component_patch_template ".values.images.csiAttacher" ".image.csi.attacher"
  update_component_patch_template ".values.images.csiProvisioner" ".image.csi.provisioner"
  update_component_patch_template ".values.images.csiNodeDriverRegistrar" ".image.csi.nodeDriverRegistrar"
  update_component_patch_template ".values.images.csiSnapshotter" ".image.csi.snapshotter"
  update_component_patch_template ".values.images.csiLivenessProbe" ".image.csi.livenessProbe"
  update_component_patch_template ".values.images.csiResizer" ".image.csi.resizer"

  rm -rf ${longhornTempChart}
}

update_component_patch_template() {
  componentTemplateKey="${1}"
  dependencyValuesKey="${2}"
  repository=$(yq "${dependencyValuesKey}.repository" < ${longhornValues})
  tag=$(yq "${dependencyValuesKey}.tag" < ${longhornValues})

  yq -i "${componentTemplateKey} = \"${repository}:${tag}\"" "${componentTemplateFile}"
}

update_versions_stage_modified_files() {
  git add "${componentTemplateFile}"
}
