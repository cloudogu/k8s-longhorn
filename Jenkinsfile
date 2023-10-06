#!groovy
@Library('github.com/cloudogu/ces-build-lib@1.65.0')
import com.cloudogu.ces.cesbuildlib.*

git = new Git(this, "cesmarvin")
git.committerName = 'cesmarvin'
git.committerEmail = 'cesmarvin@cloudogu.com'
gitflow = new GitFlow(this, git)
github = new GitHub(this, git)
changelog = new Changelog(this)

repositoryName = "k8s-longhorn"
productionReleaseBranch = "main"

node('docker') {
    timestamps {
        catchError {
            timeout(activity: false, time: 60, unit: 'MINUTES') {
                stage('Checkout') {
                    checkout scm
                    make 'clean'
                }

                helmImage = "alpine/helm:3.13.0"
                stage("Lint k8s Resources") {
                    new Docker(this)
                            .image(helmImage)
                            .inside("-v ${WORKSPACE}/:/data -t --entrypoint=")
                                    {
                                        sh "helm lint /data/k8s/helm"
                                    }
                }
            }
        }

        stageAutomaticRelease()
    }
}

void stageAutomaticRelease() {
    if (gitflow.isReleaseBranch()) {
        Makefile makefile = new Makefile(this)
        String releaseVersion = git.getSimpleBranchName()
        String registryVersion = makefile.getVersion()
        String registryNamespace = "k8s"
        String registryUrl = "registry.cloudogu.com"

        stage('Finish Release') {
            gitflow.finishRelease(releaseVersion, productionReleaseBranch)
        }

        stage('Generate release resource') {
            make 'generate-release-resource'
        }

        stage('Push to Registry') {
            GString targetLonghornResourceYaml = "target/make/k8s/${repositoryName}_${registryVersion}.yaml"

            DoguRegistry registry = new DoguRegistry(this)
            registry.pushK8sYaml(targetLonghornResourceYaml, repositoryName, registryNamespace, "${registryVersion}")
        }

        stage('Push Helm chart to Harbor') {
            new Docker(this)
                    .image("golang:1.20")
                    .mountJenkinsUser()
                    .inside("--volume ${WORKSPACE}:/${repositoryName} -w /${repositoryName}")
                            {
                                make 'longhorn-k8s-helm-package-release'

                                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'harborhelmchartpush', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD']]) {
                                    sh ".bin/helm registry login ${registryUrl} --username '${HARBOR_USERNAME}' --password '${HARBOR_PASSWORD}'"
                                    sh ".bin/helm push target/make/k8s/helm/${repositoryName}-${registryVersion}.tgz oci://${registryUrl}/${registryNamespace}"
                                }
                            }
        }

        stage('Add Github-Release') {
            releaseId = github.createReleaseWithChangelog(releaseVersion, changelog, productionReleaseBranch)
        }
    }
}

void make(String makeArgs) {
    sh "make ${makeArgs}"
}
