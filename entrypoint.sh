#!/bin/bash

datadir="/var/lib/mysql"

if [ ! -d "$datadir/mysql" ];
then
	mysql_install_db --datadir="$datadir"
fi

chown mysql /var/lib/mysql -R
