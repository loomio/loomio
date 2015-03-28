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
