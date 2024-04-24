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
            volumeMounts:
              - name: maven-cache
                mountPath: /home/jenkins/.m2
          - name: sonarcli
            image: sonarsource/sonar-scanner-cli:latest
            command:
            - cat
            tty: true
            volumeMounts:
              - name: maven-cache
                mountPath: /home/jenkins/.m2
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: Always
            command:
            - sleep
            args:
              - 9999999
            volumeMounts:
              - name: kaniko-secret
                mountPath: /kaniko/.docker
          - name: utils
            image: otisnado/utils:v2.0.1
            command:
            - cat
            tty: true
            volumeMounts:
              - name: trivy-cache
                mountPath: /home/jenkins/.cache
          volumes:
            - name: kaniko-secret
              secret:
                secretName: kaniko-secret
            - name: maven-cache
              hostPath:
                path: /root/.m2
            - name: trivy-cache
              hostPath:
                path: /root/.cache
        '''
        }
    }

    stages {
        stage('Build Stage') {
      steps {
        container('maven') {
          sh 'mvn -B clean package'
          sh 'whoami && pwd && ls -la'
        }
      }
        }

        stage('SonarQube Analysis') {
      steps {
        container('maven') {
          withSonarQubeEnv(installationName: 'SonarQubeConnection') {
            sh "mvn clean verify sonar:sonar -Dsonar.projectKey=root_hello-world-java_314a7664-bb1d-4f4f-8bac-05e6fc8b8d9a -Dsonar.projectName='Hello World Java'"
            sh 'whoami && pwd && ls -la'
          }
        }
      }
        }

        stage('Build and push container image') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor --context `pwd` --destination ${DOCKERHUB_USER}/${JOB_NAME}:${BUILD_NUMBER}'
          sh 'whoami && pwd && ls -la'
        }
      }
        }

        stage('Scan container image') {
          steps {
            container('utils') {
              sh 'trivy image ${DOCKERHUB_USER}/${JOB_NAME}:${BUILD_NUMBER} --timeout 10m --output report.html || true'
              sh 'whoami && pwd && ls -la'
            }
            publishHTML target: [
              allowMissing: true,
              alwaysLinkToLastBuild: false,
              keepAll: true,
              reportDir: '.',
              reportFiles: 'report.html',
              reportName: 'Trivy Report',
            ]
          }
        }
    }
}
