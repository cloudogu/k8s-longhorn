#!groovy
@Library('github.com/cloudogu/ces-build-lib@1.58.0')
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

                kubevalImage = "cytopia/kubeval:0.15"

                stage("Lint k8s Resources") {
                    new Docker(this)
                            .image(kubevalImage)
                            .inside("-v ${WORKSPACE}/manifests/:/data -t --entrypoint=")
                                    {
                                        sh "kubeval manifests/longhorn.yaml --ignore-missing-schemas"
                                    }
                }
            }
        }

        stage('Release') {
            stageAutomaticRelease()
        }
    }
}

void stageAutomaticRelease() {
    if (gitflow.isReleaseBranch()) {
        Makefile makefile = new Makefile(this)
        String releaseVersion = git.getSimpleBranchName()
        String registryVersion = makefile.getVersion()

        stage('Finish Release') {
            gitflow.finishRelease(releaseVersion, productionReleaseBranch)
        }

        stage('Generate release resource') {
            make'generate-release-resource'
        }

        stage('Push to Registry') {
            GString targetLonghornResourceYaml = "target/make/k8s/${repositoryName}_${registryVersion}.yaml"

            DoguRegistry registry = new DoguRegistry(this)
            registry.pushK8sYaml(targetLonghornResourceYaml, repositoryName, "k8s", "${registryVersion}")
        }

        stage('Add Github-Release') {
            releaseId = github.createReleaseWithChangelog(releaseVersion, changelog, productionReleaseBranch)
        }
    }
}

void make(String makeArgs) {
    sh "make ${makeArgs}"
}
