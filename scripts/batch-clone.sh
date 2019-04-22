#!/bin/bash
set -e

GROUP='group'
SERVICES='service1 service2 service3'
echo 'backup start'
for service in $SERVICES
do
	if [ ! -d $service ]; then
  		echo 'git clone'
		git clone git@github.com:/$GROUP/$service.git
	fi
	cd $service
	echo 'git fetch'
	git fetch --all
	cd ..
	echo $service 'bakcup down'
done