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

-----------------------------------

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

If you see this error:
"Warning: watch EMFILE Used --force, continuing"
you may need to upgrade your OS, or do a search for solutions.

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
  `$ lineman grunt spec-e2e
# -- Server env --

RACK_ENV=development

APP_LOGO_PATH
# CANONICAL_HOST
Hostname of the loomio instance. For us it's "www.loomio.org"

# DEFAULT_SUBDOMAIN
Groups can have subdomains rather than paths to locate them. ie: plainka.loomio.org rather than www.loomio.org/g/2423d23/palinka. Default subdomain is usually "www".

# DELAY_FAYE
When sending messages to the FAYE websocket server, use delayed job. This is a dumb hack incase the websocket server is down, so that that error does not break the user experience.

# DEVISE_SECRET
generate a secret with rake secret and use it here.

# Should we try to send messages to the websocket server. IE: is the 1.0 interface live updating enabled? and have you setup your FAYE server?
#
FAYE_ENABLED
FAYE_URL

# Should all links be https? If so enable this and we'll force all traffic to be https
FORCE_SSL

# If you are hosting www.loomio.org then enable this. the loomio marketing will show. You do not want to set this ever
SHOW_COMMERCIAL_PAGE
SHOW_LOOMIO_ORG_MARKETING

# Email setttings - see config/environments/production.rb and http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
SMTP_DOMAIN
SMTP_PASSWORD
SMTP_PORT
SMTP_SERVER
SMTP_USERNAME

# REPLY_HOSTNAME
So that people can reply by email, you can setup a loomo-email-gateway box. This needs an address such as reply.loomio.org. We generate custom email addresses for custombit@ENV['REPLY_HOSTNAME'] so that you can reply by email.


# ALLOW_ROBOTS
Set to 1 if you want to allow robots (search engines) to crawl the public data of the site. In practice this controls the robots.txt file.

# -- 3rd party services --

## Amazon AWS for attachments
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_BUCKET

## Social media
FACEBOOK_KEY
FACEBOOK_SECRET
TWITTER_KEY
TWITTER_SECRET
FB_APP_ID_META

## Stats / Diagnostics
AIRBRAKE_API_KEY
HEAP_APP_ID
INTERCOM_APP_API_KEY
INTERCOM_APP_ID
INTERCOM_APP_SECRET
METRICS_LISTENER_URL
METRICS_NAMESPACE
NEW_RELIC_APP_NAME
TAG_MANAGER_ID

## Translation related
BING_TRANSLATE_APPID
BING_TRANSLATE_SECRET
TRANSIFEX_PASSWORD
TRANSIFEX_USERNAME

## Errbit/Airbrake
ERRBIT_KEY
ERRBIT_HOST
ERRBIT_PORT


# -- Deprecated --

GMAIL_PASSWORD
GMAIL_USER_NAME
YAHOO_KEY
YAHOO_SECRET

# -- ??? ---

BUNDLE_GEMFILE
CFLAGS
GEM_HOME
GEM_PATH
GOOGLE_KEY
GOOGLE_SECRET
LIBS
MAX_THREADS
MIN_THREADS
NO_RUBYGEMS
OMNI_CONTACTS_GOOGLE_KEY
OMNI_CONTACTS_GOOGLE_SECRET
PARSE_GROUP_ID
PARSE_ID
PARSE_KEY
PARSE_SUBDOMAIN
PUMA_WORKERS
SECRET_COOKIE_TOKEN
TLD_LENGTH
UNICORN_TIMEOUT
UNICORN_WORKERS
callbackName

## find the ENV currently in use in the app using :
##   grep -rIso -P "(?<=ENV)(\.fetch\(|\[).[A-Z_]+.(\)|\])"

# for a uniq ordered list of env vars:
##   grep -rIsoh -P "(?<=ENV)(\.fetch\(|\[).[A-Z_]+.(\)|\])" | grep -oP "[A-Z_]+" | sort -u > temp
