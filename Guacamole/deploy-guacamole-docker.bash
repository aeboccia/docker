#!/bin/bash
VERSION="0.9.14"
guacamole_volume_path="/opt/guacamole"
compose_temp="docker-compose.yml.template"
compose_final="docker-compose.yml"
auth_jdbc="http://apache.mirror.gtcomm.net/guacamole/${VERSION}-incubating/binary/guacamole-auth-jdbc-${VERSION}-incubating.tar.gz"
dual_factor="http://apache.mirror.gtcomm.net/guacamole/${VERSION}-incubating/binary/guacamole-auth-duo-${VERSION}-incubating.tar.gz"

#Check for docker-compose
docker-compose version > /dev/null
if [ $? -ne 0 ]
then
	echo
	echo "Docker Compose is either not installed or missing from your path, please install Docker Compose or add it to your path"
	echo
	echo "See https://docs.docker.com/compose/install/#install-compose"
	exit 1
fi

read -s -p "Enter the password that will be used for MySQL Root: " MYSQLROOTPASSWORD
echo
read -s -p "Enter the password that will be used for the Guacamole database: " GUACDBUSERPASSWORD

cp $compose_temp $compose_final
sed -i "s/MYSQLROOTPASSWORD/$MYSQLROOTPASSWORD/g" $compose_final
sed -i "s/GUACDBUSERPASSWORD/$GUACDBUSERPASSWORD/g" $compose_final

# Download the guacamole auth files for MySQL and Duo Auth
wget $auth_jdbc
wget $dual_factor
tar -xzf guacamole-auth-jdbc-${VERSION}-incubating.tar.gz

#Prep Volume Data
mkdir -p $guacamole_volume_path/extensions
tar -xzf guacamole-auth-duo-${VERSION}-incubating.tar.gz && mv guacamole-auth-duo*/*.jar $guacamole_volume_path/extensions

#Copy our custom config
cp guacamole.properties $guacamole_volume_path

#Bring up all containers
docker-compose up -d

#Sleep so the mysql container may run
echo "Sleeping for 20 to allow MYSQL to come up"
sleep 20

#Prep the DB
# SQL Code
SQLCODE="
create database guacamole_db;
create user 'guacamole_user'@'%' identified by '$GUACDBUSERPASSWORD';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'%';
flush privileges;"

# Execute SQL Code
echo $SQLCODE | mysql -h 127.0.0.1 -P 3306 -u root -p$MYSQLROOTPASSWORD
cat guacamole-auth-jdbc-${VERSION}-incubating/mysql/schema/*.sql | mysql -u root -p$MYSQLROOTPASSWORD -h 127.0.0.1 -P 3306 guacamole_db

#Clean up
rm -rf guacamole-auth-*
rm $compose_final
