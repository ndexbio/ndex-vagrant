#!/usr/bin/env bash

# Check for NDEx tarball
cd /opt
ndextarball=`find /vagrant -name "ndex-*.tar.gz"`
if [ $? -ne 0 ] ; then
  echo "ERROR no NDEx tarball found. A zip file that contains the tarball can be "
  echo "downloaded from https://home.ndexbio.org/ftp_page/"
  exit 1
fi

if [ ! -f "$ndextarball" ] ; then
  echo "ERROR no NDEx tarball found. A zip file that contains the tarball can be "
  echo "downloaded from https://home.ndexbio.org/ftp_page/"
  exit 1
fi
ndextarballname=`basename $ndextarball`
echo "ndextarball => $ndextarball"
echo "ndextarballname => $ndextarballname"

# add ndex user
useradd -r -m -U ndex

# install base packages
dnf install -y epel-release git gzip tar java-21-openjdk java-21-openjdk-devel wget httpd lsof
dnf module reset postgresql -y
dnf module enable postgresql:15 -y
dnf install -y postgresql-server glibc-all-langpacks
dnf install -y python39

# pip3 install gevent
# pip3 install gevent_websocket
# pip3 install bottle

# pysolr is probably no longer needed
# pip install pysolr

# initialize postgres database and set it to startup upon boot
postgresql-setup --initdb --unit postgresql
systemctl enable postgresql
systemctl start postgresql

# Install ndex tarball
echo "Using $ndextarballname as source for ndex"
cp $ndextarball .
tar -zxf $ndextarballname
mv `echo $ndextarballname | sed "s/\.tar\.gz//"` ndex
chown -R ndex.ndex ndex

# copy over systemd scripts
cp /vagrant/systemd/ndex-solr.service /etc/systemd/system/.
cp /vagrant/systemd/ndex-tomcat.service /etc/systemd/system/.
cp /vagrant/systemd/ndex-query-engine2.service /etc/systemd/system/.

# enable systemd scripts
systemctl enable ndex-solr.service
systemctl enable ndex-tomcat.service
systemctl enable ndex-query-engine2.service


# copy over apache config for ndex
cp /vagrant/ndex.conf /etc/httpd/conf.d/.
chmod go-wx /etc/httpd/conf.d/ndex.conf

# initialize postgres database
sudo -u postgres psql < /vagrant/psql.cmds
sudo -u postgres psql ndex < /opt/ndex/scripts/ndex_db_schema.sql

# Add postgres user permissions
echo "local ndex ndexserver md5" > /tmp/pg_hba.conf
echo "host ndex ndexserver 127.0.0.1/32 trust" >> /tmp/pg_hba.conf
cat /var/lib/pgsql/data/pg_hba.conf >> /tmp/pg_hba.conf
mv -f /tmp/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf

# restart postgres service
service postgresql restart

# Fix url in ndex-webapp-config.js
cat /opt/ndex/conf/ndex-webapp-config.js | sed  "s/^ *ndexServerUri:.*/    ndexServerUri: \"http:\/\/localhost:8081\/v2\",/g" > /tmp/t.json
mv -f /tmp/t.json /opt/ndex/conf/ndex-webapp-config.js
chown ndex.ndex /opt/ndex/conf/ndex-webapp-config.js

# Fix HostURI in ndex.properties
cat /opt/ndex/conf/ndex.properties | sed "s/^ *HostURI.*=.*$/HostURI=http:\/\/localhost:8081/g" > /tmp/n.properties
mv -f /tmp/n.properties /opt/ndex/conf/ndex.properties

# Enable httpd access to port
/usr/sbin/setsebool -P httpd_can_network_connect 1

# Start apache
service httpd start

# start solr
systemctl start ndex-solr

# start neighborhood query service
systemctl start ndex-query-engine2

# start tomcat
systemctl start ndex-tomcat

# install miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod a+x Miniconda3-latest-Linux-x86_64.sh

sudo -u ndex ./Miniconda3-latest-Linux-x86_64.sh -p /opt/ndex/miniconda3 -b
rm -f Miniconda3-latest-Linux-x86_64.sh

/opt/ndex/miniconda3/bin/pip install ndex_webapp_python_exporters
/opt/ndex/miniconda3/bin/pip install ndex2
sleep 10

echo "On your browser visit http://localhost:8081"
