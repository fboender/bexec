#!/bin/sh

#
# Script that runs queries in a file against a SQLite3 database.
#

DBFILE="/path/to/database"

grep -v "^#" $1 | sqlite3 -header -column $DBFILE 2>&1
