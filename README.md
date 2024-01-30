# Hello World Java Spring App

To run this app you need to have the following tools in your system
- OpenJDK-17
- Docker (If you want to run in container)

To build docker image run: 
`````
docker build -t ${yourImageName} .
`````

To run only Spring Boot App run:
````
mvn spring-boot:run
````

## Endpoints
This app has 2 endpoints
* "/" endpoint that return a hello world message with the hostname of the machine where is runnig
* "/actuator/*" that return information about health of App. This endpoint is used to config liveness probe for K8s deployment

## Resources
In folder `./k8s` at repository root level you can find k8s YAML files to deploy application
````
hello-world-java
---- k8s
-------- 00-namespace.yaml
-------- 01-deployment.yaml
-------- 02-service.yaml
````

## CI/CD tool
Jenkins is used to build java artifact, analyze code, build and push to private reigstry in Amazon ECR container image with Kaniko and deploy to K8s cluster using Amazon EKS 

You can find repo of Hello world app in the follow [Link](https://github.com/otisnado/hello-world-java.git)