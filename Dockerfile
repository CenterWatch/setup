FROM mysql:latest 
ENV MYSQL_ROOT_PASSWORD="root"
ENV MYSQL_DATABASE="cwdb"
COPY bd_script.sql /docker-entrypoint-initbd.d/
EXPOSE 3306