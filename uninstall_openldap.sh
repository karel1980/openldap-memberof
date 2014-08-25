#!/bin/bash

service slapd stop
yum -y remove openldap-servers openldap-clients
rm -Rf /etc/openldap
yum -y reinstall openldap
