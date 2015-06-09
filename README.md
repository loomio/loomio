<h1><a href="https://www.loomio.org"> <img src="app/assets/images/logo-orange.png" alt="Loomio"/></a> </h1>
 
[![Build Status](https://img.shields.io/travis/loomio/loomio.svg)](https://travis-ci.org/loomio/loomio) 
[![Code Climate](https://img.shields.io/codeclimate/github/loomio/loomio.svg)](https://codeclimate.com/github/loomio/loomio) 
[![Dependency Status](https://img.shields.io/gemnasium/loomio/loomio.svg)](https://gemnasium.com/loomio/loomio) 

Loomio is a collaborative decision-making tool that makes it easy for anyone to participate in decisions which affect them. If you'd like to find out more, check out [Loomio.org](https://www.loomio.org).

- Issues and __bugs__ should be [reported here](http://github.com/loomio/loomio/issues)
- To learn how to __setup__, __develop__ or __translate__ Loomio [visit the wiki](https://github.com/loomio/loomio/wiki).
- To see what's being worked on and what's planned, vote on development priorities, and find tasks to pick up, check out the [Loomio Roadmap](https://www.loomio.org/roadmap). To participate in discussions about the app, potential features, and more, [join the Loomio Community group on Loomio](https://www.loomio.org/g/WmPCB3IR/loomio-community).

### Contact

If you have any questions or feedback, get in touch via [contact@loomio.org](mailto:contact@loomio.org).
<br />
[Facebook](https://facebook.com/Loomio) [Twitter](https://twitter.com/Loomio) [Google+](https://plus.google.com/+LoomioOrg)

## Requirements
- PostgreSQL version 9.4 or higher.
- Ruby 2.1

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

  `$ npm install -g protractor`  
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

# Configuration

### Domain name settings
CANONICAL_HOST - Hostname of the loomio instance. For us it's "www.loomio.org"
TLD_LENGTH - length of the top level part of your domain name.
DEFAULT_SUBDOMAIN - we use www
ALLOW_ROBOTS - Set to 1 if you want to search engines to crawl the public discussions and groups.

Examples:
  www.loomio.org
  CANONICAL_HOST = www.loomio.org
  TLD_LENGTH = 1
  DEFAULT_SUBDOMAIN = www
 
  loomio.somewhereelse.com
  CANONICAL_HOST = loomio.somewhereelse.com
  TLD_LENGTH = 2
  DEFAULT_SUBDOMAIN should not be set

SECRET_COOKIE_TOKEN -  run 'rake secret' to generate your own SECRET_COOKIE_TOKEN
DEVISE_SECRET - run 'rake secret' to generate your own DEVISE_SECRET
FORCE_SSL - if true, only HTTPS connections will be permitted
FAYE_ENABLED - If you have a instance of https://github.com/loomio/private_pub
FAYE_URL - the url for your FAYE instance
MAX_THREADS - optional puma configuration
MIN_THREADS - optional puma configuration
PUMA_WORKERS - optional puma configuration

### Email configuration

SMTP_DOMAIN  
SMTP_PASSWORD  
SMTP_PORT  
SMTP_SERVER  
SMTP_USERNAME  
REPLY_HOSTNAME - we use reply.loomio.org. This is the hostname of your reply by email server.


### Amazon AWS for attachments
AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  
AWS_BUCKET  

### Social media
FACEBOOK_KEY  
FACEBOOK_SECRET  
TWITTER_KEY  
TWITTER_SECRET  
FB_APP_ID_META  
GOOGLE_KEY  
GOOGLE_SECRET  
OMNI_CONTACTS_GOOGLE_KEY  
OMNI_CONTACTS_GOOGLE_SECRET  

### Analytics
HEAP_APP_ID  
NEW_RELIC_APP_NAME  
TAG_MANAGER_ID  

### Translation related
BING_TRANSLATE_APPID  
BING_TRANSLATE_SECRET  

### Errbit/Airbrake
ERRBIT_KEY  
ERRBIT_HOST  
ERRBIT_PORT  

#### find the ENV currently in use in the app using : 
`grep -rIso -P "(?<=ENV)(\.fetch\(|\[).[A-Z_]+.(\)|\])"`

#### for a uniq ordered list of env vars:
`grep -rIsoh -P "(?<=ENV)(\.fetch\(|\[).[A-Z_]+.(\)|\])" | grep -oP "[A-Z_]+" | sort -u > temp`
