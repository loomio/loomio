<h1><a href="https://www.loomio.org"> <img src="app/assets/images/logo-orange.png" alt="Loomio"/></a> </h1>
 
[![Build Status](https://img.shields.io/travis/loomio/loomio.svg)](https://travis-ci.org/loomio/loomio) 
[![Code Climate](https://img.shields.io/codeclimate/github/loomio/loomio.svg)](https://codeclimate.com/github/loomio/loomio) 
[![Dependency Status](https://img.shields.io/gemnasium/loomio/loomio.svg)](https://gemnasium.com/loomio/loomio) 

Loomio is a collaborative decision-making tool that makes it easy for anyone to participate in decisions which affect them. If you'd like to find out more, check out [Loomio.org](https://www.loomio.org).

- Issues and __bugs__ should be [reported here](http://github.com/loomio/loomio/issues)
- To learn how to __setup__, __develop__ or __translate__ Loomio [visit the wiki](https://github.com/loomio/loomio/wiki).
- To see what's being worked on and what's planned, vote on development priorities, and find tasks to pick up, check out the [Loomio Roadmap](https://www.loomio.org/roadmap). To participate in discussions about the app, potential features, and more, [join the Loomio Community group on Loomio](https://www.loomio.org/g/WmPCB3IR/loomio-community).

# Setup loomio for development
See [Setup a Loomio development environment](https://github.com/loomio/loomio/wiki/Setup-a-Loomio-development-environment) our github wiki for a step by step guide to setting up your computer to develop on Loomio. If you are familiar with the process of running rails apps you can just fork and clone the repo, `bundle install` then `rake db:setup`.

## Installing the frontend dependencies

The new javascript frontend is a [linemanjs](http://linemanjs.com/) project.

You'll need bower and lineman installed:

  `$ npm install -g bower`  
  `$ npm install -g lineman`

Fetch the npm and bower dependencies:

  from within loomio/lineman/
  `$ npm install`  
  `$ bower install`

## Trying the new user interface in development mode
Run the rails development server

  `$ rails s`  

Then start lineman from the loomio/lineman folder  

  `$ lineman run`

We have links that can setup some fake data and log you in:

  http://localhost:8000/development/start_discussion

See the app/controllers/development_controller.rb for more.

## Testing
We have rspec and cucumber tests on the rails app.

### Rspec and Cucumber for the rails app
We unit test the rails app with rspec, and have intregration tests of
the rails based UI in cucumber.

We also unit and e2e test the new javascript frontend.

### Jasmine and Protractor for the frontend

You can run the frontend unit tests with

  `$ lineman spec`

### Running e2e tests

If you don't have them already, install protractor and webdriver-manager:

  `$ npm install -g protractor`  
  `$ webdriver-manager update --standalone`  

Protractor e2e tests require rails, lineman and webdriver-manager to be
running at the same time:

  Start webdriver-manager from anywhere
  `$ webdriver-manager start`  

  Start rails from the loomio folder
  `$ rails s`

  Start lineman from loomio/lineman
  `$ lineman run`  

  Run the tests themselves from loomio/lineman
  `$ lineman grunt spec-e2e`


# Production Configuration

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

## Requirements
- PostgreSQL version 9.4 or higher.
- Ruby 2.2

### Contact

If you have any questions or feedback, get in touch via [contact@loomio.org](mailto:contact@loomio.org).
<br />
[Facebook](https://facebook.com/Loomio) [Twitter](https://twitter.com/Loomio) [Google+](https://plus.google.com/+LoomioOrg)
