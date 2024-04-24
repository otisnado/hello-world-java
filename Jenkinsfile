pipeline {
    agent {
        kubernetes {
            yaml '''
        apiVersion: v1
        kind: Job
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

        // stage('SonarQube Analysis') {
        //     steps {
        //         container('maven'){
        //             def mvn = tool 'Default Maven';
        //             withSonarQubeEnv() {
        //                 sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=root_hello-world-java_314a7664-bb1d-4f4f-8bac-05e6fc8b8d9a -Dsonar.projectName='Hello World Java'"
        //             }
        //         }
        //     }        

        // stage('Wait for Quality Gate'){
        //     steps{
        //         container('sonarcli'){
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //             }
        //         }
        //     }
        // }

        // stage('Build and Push container image') {
        //     steps {
        //         container('kaniko') {
        //             sh '/kaniko/executor --context `pwd` --destination ${AWS_ECR}:${BUILD_ID}'
        //         }
        //     }
        // }

        // stage('Deploy to K8s') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'AWSCredentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]){
        //             container('k8s-deploy'){
        //                 sh 'aws eks update-kubeconfig --region us-east-1 --name developmentCluster --kubeconfig `pwd`/config'
        //                 sh 'kubectl apply -f k8s/00-namespace.yaml --kubeconfig=config'
        //                 sh 'kubectl --kubeconfig=config set image -f k8s/01-deployment.yaml hello-world-java=${AWS_ECR}:${BUILD_ID} --local -o yaml | kubectl --kubeconfig=config apply -f -'
        //                 sh 'kubectl apply -f k8s/02-service.yaml --kubeconfig=config'
        //             }
        //         }
        //     }
        // }

    }
}
