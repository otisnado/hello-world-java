FROM openjdk:17-jdk-alpine

# Exposing app port
EXPOSE 8080

# Creating specific app user and group to run app
RUN addgroup -g 1199 appgroup && adduser -H -s /sbin/nologin -u 1199 -G appgroup -D appuser

# Creating and setting working directory
RUN mkdir /app && chown -R appuser:appgroup /app && chmod 744 -R /app
WORKDIR /app

# Setting user to run application inside container
USER appuser

# Copying app artifact
COPY target/helloWorld*.jar app.jar

# Debug option
ARG VERBOSE=true

# Entry point to run app
ENTRYPOINT [ "java", "-jar", "/app/app.jar" ]