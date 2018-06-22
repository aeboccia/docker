Guacamole - A shell script, supporting configs and docker-compose for spinning up a 4 container Guacamole server in docker with Duo Auth support, an NGINX https proxy in front and MYSQL for the DB backend.
  - To utilize, simply run the bash script and provide 2 passwords, the first for MYSQL root user and the second for the Guacamole user.
  - For Nginx SSL, be sure to substitute the placeholder certs with your own.
  - By default all volumes and files will reside under /opt/ for the containers, you may change this by editing the deploy script and changing guacamole_volume_path variable to your preferred path
  - To configure DUO follow the steps for how to obtain your API info and Keys from https://guacamole.apache.org/doc/gug/duo-auth.html and add them to guacamole.properties
  - Note: The bash script will generate a docker compose from the template which contains your passwords, after the script completes it will delete the docker-compose.yml file
