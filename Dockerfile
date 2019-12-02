FROM golang:1.12.0-alpine3.9 AS trivago-go
COPY golang-webserver golang-webserver
ENTRYPOINT ["./golang-webserver"]

FROM openjdk:11-jdk AS trivago-java
COPY java-webserver.jar java-webserver.jar
ENTRYPOINT ["java","-jar","/java-webserver.jar"]