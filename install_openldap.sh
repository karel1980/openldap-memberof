#!/bin/bash

set -e

yum install -y openldap openldap-clients openldap-servers

sed -i 's/SLAPD_LDAPS=no/SLAPD_LDAPS=yes/' /etc/sysconfig/ldap

service slapd restart

sleep 5

cd $(dirname $0)

echo "Creating database"
mkdir -p /disk1/ldap/; chmod 700 /disk1/ldap/; chown ldap:ldap /disk1/ldap/
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /disk1/ldap/DB_CONFIG

ldapadd -Y EXTERNAL -H ldapi:/// -f ldif/database.ldif

echo "Creating overlays"
ldapadd -Y EXTERNAL -H ldapi:/// -f ldif/memberof.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f ldif/refint.ldif

echo "Configuring SSL"
#ldapadd -Y EXTERNAL -H ldapi:/// -f ldif/certconfig.ldif

service slapd restart

echo "Adding top-level structure and system users"
ldapadd -c -Y EXTERNAL -H ldapi:/// -f ldif/adminuser.ldif

echo "Adding Group ou"
ldapadd -c -Y EXTERNAL -H ldapi:/// -f ldif/groupnode.ldif

echo "Adding Users"
ldapadd -c -Y EXTERNAL -H ldapi:/// -f ldif/users.ldif

echo "Adding groups"
ldapadd -c -Y EXTERNAL -H ldapi:/// -f ldif/groups.ldif

