pipeline {
    agent {
        kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
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
                mountPath: /root/.m2
          - name: sonarcli
            image: sonarsource/sonar-scanner-cli:latest
            command:
            - cat
            tty: true
            volumeMounts:
              - name: maven-cache
                mountPath: /root/.m2
              - name: sonar-cache
                mountPath: /root/.sonar/cache
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
            image: otisnado/utils:v3.0.0
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
            - name: sonar-cache
              hostPath:
                path: /root/.sonar/cache
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
            sh '/tools/dotnet-gitversion `pwd` /output buildserver /outputfile ./gitversion.properties'

            script {
              def props = readProperties file: 'gitversion.properties'

              env.GitVersion_SemVer = props.GitVersion_SemVer
              env.GitVersion_BranchName = props.GitVersion_BranchName
              env.GitVersion_AssemblySemVer = props.GitVersion_AssemblySemVer
              env.GitVersion_MajorMinorPatch = props.GitVersion_MajorMinorPatch
              env.GitVersion_Sha = props.GitVersion_Sha
            }
            
          }
        }
      }

      stage('Build Stage') {
        steps {
          container('maven') {
            sh 'mvn build-helper:parse-version versions:set -DnewVersion="${GitVersion_SemVer}"'
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
            sh '/kaniko/executor --context `pwd` --destination ${DOCKERHUB_USER}/${JOB_NAME}:${GitVersion_SemVer}'
          }
        }
      }

      stage('Scan container image') {
        steps {
          container('utils') {
            sh 'trivy image --server ${TRIVY_SERVER} --scanners vuln --severity HIGH,CRITICAL,MEDIUM,LOW ${DOCKERHUB_USER}/${JOB_NAME}:${GitVersion_SemVer} --format template --template "@/home/jenkins/agent/trivy/html.tpl" --timeout 10m --output report.html || true'
          }

          publishHTML target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: '.',
            reportFiles: 'report.html',
            reportName: 'Trivy Report',
          ]

        }
      }

      stage('Checkout Helm Chart repository'){
        steps{
          container('utils'){
            cleanWs()
            git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/otisnado/helmcharts.git'
          }
        }
      }

      stage('Package Helm Chart'){
        steps{
          container('utils'){
            sh 'helm package ${JOB_NAME} --app-version ${GitVersion_SemVer} --version ${GitVersion_SemVer} --destination `pwd`/charts'
            sh 'ls -lah charts'
          }
        }
      }

      stage('Index Helm repository'){
        steps{
          container('utils'){
            sh 'helm repo index .'
            sh 'cat index.yaml'
          }
        }
      }

      stage('Push Helm Chart'){
        steps{
          container('utils'){
            sh 'ls -lah'
            sh 'git config --add safe.directory `pwd`'
            sh 'git config user.email "jenkins-agent@otisnado.com"'
            sh 'git config user.name "${BUILD_TAG}"'
            sh 'git add index.yaml charts/${JOB_NAME}-${GitVersion_SemVer}.tgz ${JOB_NAME}/Chart.yaml'
            sh 'git commit -m "Update appVersion and chart version in ${JOB_NAME} chart"'
            sh 'git push'
          }
        }
      }
    }
}
