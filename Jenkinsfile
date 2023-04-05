pipeline {
  agent any

  stages {

    stage('build-latest') {
      environment {
        DOCKER_TAG_NAME = "latest"
      }
      when {
        branch 'master'
      }
      steps {
        sh 'make docker-release'
      }
    }

    stage('build-release') {
      when {
        branch 'master'
        changeset "VERSION"
      }
      steps {
        sh 'make docker-release-version'
      }
    }

  }

  post {
    always {
      mail to: 'dean@deanpcmad.com', from: 'jenkins@d34n.uk',
        subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}",
        body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n\nBlue Ocean:\n${env.RUN_DISPLAY_URL}"
    }
  }
}
