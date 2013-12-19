# Loomio AngularJS Frontend


# Installing support applications
install npm
npm install -g bower

# Installing Dependencies
npm install
bower install

# Running
lineman run

# Testing
lineman run &
RAILS_ENV=test rails s  
webdriver-manager start
lineman grunt cucumberjs

rake db:test:prepare
rake loomio:angular-testing:setup_fixtures

# New commands to know

pull in dependencies not in the repo
npm install
bower install

install a new npm thing
npm install thingname --save-dev

install a new bower component
bower install thingname
