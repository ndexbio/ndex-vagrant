#!/usr/bin/env bash

# install base packages
yum install -y epel-release git gzip tar java-1.8.0-openjdk java-1.8.0-openjdk-devel wget httpd lsof
yum install -y python2-pip
pip install gevent
pip install gevent_websocket
pip install bottle 

# pysolr is probably no longer needed
pip install pysolr

# open port 80 for http
firewall-cmd --permanent --add-port=80/tcp

# open port 8080 for http
firewall-cmd --permanent --add-port=8080/tcp

# restart firewalld
service firewalld restart

# download and install postgres 9.5
yum install -y https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-3.noarch.rpm
yum install -y postgresql95 postgresql95-server

# initialize postgres database and set it to startup upon boot
/usr/pgsql-9.5/bin/postgresql95-setup initdb
systemctl enable postgresql-9.5
systemctl start postgresql-9.5

# add ndex user
useradd -M -r -s /bin/false -U ndex

# download and install ndex tarball
cd /opt
wget ftp://ftp.ndexbio.org/NDEx-v2.3.1/ndex-2.3.1.tar.gz
tar -zxf ndex-2.3.1.tar.gz
chown -R ndex.ndex ndex

# copy over apache config for ndex
cp /vagrant/ndex.conf /etc/httpd/conf.d/.
chmod go-wx /etc/httpd/conf.d/ndex.conf

# initialize postgres database
sudo -u postgres psql < /vagrant/psql.cmds
sudo -u postgres psql ndex < /opt/ndex/scripts/ndex_db_schema.sql

# Add postgres user permissions
echo "local ndex ndexserver md5" > /tmp/pg_hba.conf
echo "host ndex ndexserver 127.0.0.1/32 trust" >> /tmp/pg_hba.conf
cat /var/lib/pgsql/9.5/data/pg_hba.conf >> /tmp/pg_hba.conf
mv -f /tmp/pg_hba.conf /var/lib/pgsql/9.5/data/pg_hba.conf

# restart postgres service
service postgresql-9.5 restart

# Fix url in ndex-webapp-config.js
cat /opt/ndex/conf/ndex-webapp-config.js | sed  "s/^ *ndexServerUri:.*/    ndexServerUri: \"http:\/\/localhost:8081\/v2\",/g" > /tmp/t.json
mv -f /tmp/t.json /opt/ndex/conf/ndex-webapp-config.js
chown ndex.ndex /opt/ndex/conf/ndex-webapp-config.js

service httpd start
sudo -u ndex /opt/ndex/solr/bin/solr start -m 1g
sudo -u ndex /opt/ndex/tomcat/bin/startup.sh

# install miniconda3
sudo -u ndex wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod a+x Miniconda3-latest-Linux-x86_64.sh

sudo -u ndex ./Miniconda3-latest-Linux-x86_64.sh -p /opt/ndex/miniconda3 -b

sleep 10

echo "On your browser visit http://localhost:8081"
