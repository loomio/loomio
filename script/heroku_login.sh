#!/bin/bash
echo "Logging into Heroku..."

HEROKU_USERNAME=$1
HEROKU_PASSWORD=$2
expect -c "
   log_user 0
   set timeout 60
   spawn `which heroku` login
   expect Email { send $HEROKU_USERNAME\r }
   expect Password { send $HEROKU_PASSWORD\r }
   expect $HEROKU_USERNAME
   exit
"
