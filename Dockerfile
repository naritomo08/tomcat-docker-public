FROM maven:3.8.3-openjdk-11

WORKDIR /app

COPY ./my-tomcat-project /app
