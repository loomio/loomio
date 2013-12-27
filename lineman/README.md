# Loomio AngularJS Frontend
This is the beginnings of a document to introduce people to the
AngularJS parts of Loomio. It is assumed that you have the rails parts
of loomio running already.

# Installing Node & NPM
Use NVM to install Node and NPM

  $ curl https://raw.github.com/creationix/nvm/master/install.sh | sh
  $ nvm use 0.10
  $ nvm alias default 0.10

# Installing Bower & Lineman

  $ npm install -g bower
  $ npm install -g lineman

# Installing Dependencies
in the loomio folder

  $ cd lineman
  $ npm install
  $ bower install

# Running
Run the rails development server
  (loomio) $ rails s

The start lineman
  (loomio/lineman folder) $ lineman run

# Browsing
First go to the rails app (localhost:3000) and sign in. Now you can use the javascript app at localhost:8000. Just navigate to a discussion (e.g. localhost:8000/discussions/325).

# Testing
We're going for high test coverage of our JS frontend here.
You can run the unit rests with

  $ lineman spec

To run the cucumber tests, you need a bit of environment running. It's
probably easiest if you run these each in their own terminal window.

  From the project root:
  $ rails s

  From the lineman folder:
  $ lineman run 
  $ webdriver-manager start

  Then finally to run the tests:
  $ lineman grunt cucumberjs
