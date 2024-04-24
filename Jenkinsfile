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
            volumeMounts:
              - name: kaniko-secret
                mountPath: /secret
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

        stage('SonarQube Analysis') {
            steps {
                container('maven') {
                    withSonarQubeEnv(installationName: 'SonarQubeConnection') {
                        sh "mvn clean verify sonar:sonar -Dsonar.projectKey=root_hello-world-java_314a7664-bb1d-4f4f-8bac-05e6fc8b8d9a -Dsonar.projectName='Hello World Java'"
                    }
                }
            }
        }

        stage('Build and push container image'){
            steps{
                container('kaniko'){
                    sh '/kaniko/executor --context `pwd` --destination ${DOCKERHUB_USER}/${JOB_NAME}:${BUILD_NUMBER}'
                }
            }
        }
    }
}
