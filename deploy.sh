#!/bin/bash

if [ -z ${1+x} ]; then SOURCE_BRANCH='master'; else SOURCE_BRANCH=$1; fi

echo "building angular assets and deploying branch:"
echo $BRANCH

BUILD_BRANCH=production-$(date +%Y%m%d%H%M%S)
git checkout $SOURCE_BRANCH
git checkout -b $BUILD_BRANCH
cd lineman && npm install && bower install && lineman build && cd ..
cp -R lineman/dist/* public/
cp lineman/vendor/bower_components/airbrake-js/airbrake-shim.js public/js/airbrake-shim.js
git add public/img public/css public/js public/fonts && git commit -m "production build commit" && git checkout $SOURCE_BRANCH && git push loomio-production $BUILD_BRANCH:master -f
git branch -D $BUILD_BRANCH
heroku run rake db:migrate -a loomio-production
heroku restart -a loomio-production
