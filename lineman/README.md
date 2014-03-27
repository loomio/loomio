# Loomio AngularJS Frontend
This is the beginnings of a document to introduce people to the
AngularJS parts of Loomio. It is assumed that you have the rails parts
of loomio running already.

# Installing Node
Install the latest version of node js for your system. Go find out how.

# Installing Bower & Lineman

  $ npm install -g bower
  $ npm install -g lineman

# Installing Dependencies
in the loomio folder

  $ cd lineman
  $ npm install
  $ bower install

# Running
Run the rails development server and Private Pub
  (loomio) $ rails s
           $ rackup private_pub.ru -s thin -E production

The start lineman
  (loomio/lineman folder) $ lineman run


# Browsing
First go to the rails app (localhost:3000) and sign in. Now you can use the javascript app at localhost:8000. Just navigate to a discussion (e.g. localhost:8000/discussions/325).

# Unit Testing
We're going for high test coverage of our JS frontend here.
You can run the unit tests with

  $ lineman spec

# Integration testing
We're not using linemans default e2e testing stuff. Insted we're going for cucumber.js integration tests.


## Installing Protractor & Webdriver-manager
To run the integration tests, you'll need Protractor and Webdriver-manager

  $ npm install -g protractor
  $ webdriver-manager update --standalone

## Running the cucmber tests

To run the cucumber tests, you need a bit of environment running. It's
probably easiest if you run these each in their own terminal window.

  From the project root:
  $ rails s

  From the lineman folder:
  $ lineman run 
  $ webdriver-manager start

  Then finally to run the tests:
  $ lineman grunt cucumberjs

  grunt-cucumberjs does not support the coffeescript flag in the
  latest version of cucumber.js Sooo.. rather than the above line..
  I have an alias for: 'node node_modules/cucumber/bin/cucumber.js --require features/step_definitions --coffee'
  In my shell profile, so I can run the cukes with "cjs" from the command line in my workflow and get coffeescript pending step definitations
