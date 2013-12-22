# Loomio AngularJS Frontend
This is the beginnings of a document to introduce people to the
AngularJS parts of Loomio. It is assumed that you have the rails parts
of loomio running already.

# Installing NPM and Bower
Use your system package manager to install NPM and Bower. I use HomeBrew on
OSX.

  $ brew install npm
  $ npm install -g bower

# Installing Dependencies
in the loomio folder

  $ cd lineman
  $ npm install
  $ bower install

# Running
Run the rails development server
  (loomio) $ rails s

The start lineman
  (lineman folder) $ lineman run

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
