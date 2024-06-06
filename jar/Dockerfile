FROM openjdk:17
WORKDIR /cwatching
RUN mkdir -p ./logs
COPY cwatching-monitoring.jar /cwatching/
CMD ["java","-jar","cwatching-monitoring.jar","false","6"]