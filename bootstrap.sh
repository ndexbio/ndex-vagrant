#!/usr/bin/env bash

yum install -y epel-release git gzip tar java-1.8.0-openjdk java-1.8.0-openjdk-devel wget httpd
yum install -y python2-pip
pip install gevent
pip install gevent_websocket
pip install bottle 
pip install pysolr
firewall-cmd --permanent --add-port=80/tcp
yum install -y https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-3.noarch.rpm
yum install -y postgresql95 postgresql95-server

/usr/pgsql-9.5/bin/postgresql95-setup initdb
systemctl enable postgresql-9.5
systemctl start postgresql-9.5

useradd -M -r -s /bin/false -U ndex

cd /opt
wget ftp://ftp.ndexbio.org/NDEx-v2.3.1/ndex-2.3.1.tar.gz
tar -zxf ndex-2.3.1.tar.gz
chown -R ndex.ndex ndex
cp /vagrant/ndex.conf /etc/httpd/conf.d/.
chmod go-wx /etc/httpd/conf.d/ndex.conf
