#!/bin/bash
echo "building angular and copying into public"
BRANCH=production-$(date +%Y%m%d%H%M%S)
git checkout master
git checkout -b $BRANCH # should be new branch each time
cd lineman
npm install && bower install && lineman build
cd ..
cp -R lineman/dist/* public/
git add public/img public/css/app.css public/js/app.js public/js/vendor.js public/fonts && git commit -m "production build commit" && git push loomio-production $BRANCH:master -f && rm -r public/img public/css public/js 
git checkout master
git branch -D $BRANCH
heroku run rake db:migrate -a loomio-production
heroku restart -a loomio-production
