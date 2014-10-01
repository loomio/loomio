#!/bin/sh
cd /home/app/loomio
exec /sbin/setuser app bundle exec puma -e production
