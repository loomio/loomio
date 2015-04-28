# Loomio AngularJS Frontend
This is the beginnings of a document to introduce people to the
AngularJS parts of Loomio. It is assumed that you have the rails parts
of loomio running already.

# Installing Node
Install the latest version of node.js for your system. (Some of us quite like [NVM](https://github.com/creationix/nvm))

# Installing Bower & Lineman

  `$ npm install -g bower`  
  `$ npm install -g lineman`

# Installing Dependencies
in the loomio folder  
  `$ cd lineman`  
  `$ npm install`  
  `$ bower install`

# Running
Run the rails development server and Private Pub
  (loomio) `$ rails s`  

For production environments only, run Private Pub (this is unnecessary for development)  
`$ rackup private_pub.ru -s thin -E production`


Then start lineman from the loomio/lineman folder  
`$ cd lineman`  
`$ lineman run`

# Browsing
- First go to the rails app at [localhost:3000](localhost:3000) and sign in.  
- After logging in, visit [localhost:3000/angular](localhost:3000/angular) to enable the angular dashboard for your User.  
- After activating the angular interface, you can use the javascript app at [localhost:8000](localhost:8000)

# Unit Testing
We're going for high test coverage of our JS frontend here.
You can run the unit tests with

  `$ lineman spec`

# Integration testing
We're not using linemans default e2e testing stuff. Insted we're going for cucumber.js integration tests.


## Installing Protractor & Webdriver-manager
To run the integration tests, you'll need Protractor and Webdriver-manager

  `$ npm install protractor`  
  `$ webdriver-manager update --standalone`  

(NB: This will require a java development kit to function correctly, [go here](http://docs.oracle.com/javase/7/docs/webnotes/install/) for more details on installing a JDK)

## Running e2e tests

To run the e2e tests, you need a bit of environment running. It's
probably easiest if you run these each in their own terminal window.

  From the loomio folder:  
  `$ rails s`

  From the loomio/lineman folder:  
  `$ lineman run`  
  `$ webdriver-manager start`  

  Then finally to run the tests:  
  `$ lineman grunt spec-e2e`
