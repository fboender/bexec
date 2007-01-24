#!/bin/sh

#
# Script that runs queries from a file against a MySQL database.
#

USERNAME='username'
PASSWORD='password'
HOSTNAME='hostname'
DATABASE='database'

mysql -t -u$USERNAME -p$PASSWORD -h$HOSTNAME $DATABASE < $1
