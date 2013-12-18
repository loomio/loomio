# Loomio AngularJS Frontend

# Installing
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
