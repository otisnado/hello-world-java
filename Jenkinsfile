pipeline {
    agent {
        kubernetes {
            yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:3.9.6-eclipse-temurin-17-alpine
            command:
            - cat
            tty: true
          - name: sonarcli
            image: sonarsource/sonar-scanner-cli:latest
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: Always
            command:
            - sleep
            args:
            - 9999999
          - name: k8s-deploy
            image: otisnado/utils:latest
            command:
            - cat
            tty: true
        '''
        }
    }

    stages {
        stage('Build Stage') {
            steps {
                container('maven') {
                    sh 'mvn -B clean package'
                }
            }
        }
    }

    stage('SonarQube Analysis') {
        def mvn = tool 'Default Maven'
        withSonarQubeEnv() {
            sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=root_hello-world-java_314a7664-bb1d-4f4f-8bac-05e6fc8b8d9a -Dsonar.projectName='Hello World Java'"
        }
    }
}
