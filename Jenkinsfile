pipeline {
    agent {
        kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            fsGroup: 1000
          containers:
          - name: gitversion
            image: gittools/gitversion:5.12.0
            imagePullPolicy: Always
            command:
            - cat
            tty: true
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
              - name: trivy-template
                mountPath: /home/jenkins/agent/trivy
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
            - name: trivy-template
              configMap:
                name: trivy-template
        '''
        }
    }

    stages {
      stage('Semantic version') {
        steps {
          container('gitversion') {
            sh '`pwd` /output file'
          }
        }
      }

        stage('Build Stage') {
      steps {
        container('maven') {
          sh 'ls -lah'
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

        stage('Build and push container image') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor --context `pwd` --destination ${DOCKERHUB_USER}/${JOB_NAME}:${NEXT_VERSION}'
        }
      }
        }

        stage('Scan container image') {
          steps {
            container('utils') {
              sh 'trivy image ${DOCKERHUB_USER}/${JOB_NAME}:${NEXT_VERSION} --format template --template "@/home/jenkins/agent/trivy/html.tpl" --timeout 10m --output report.html || true'
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
