# Environment Variables

### Setup environment variables

Login to your application host

dokku config:set loomio DATABASE_URL="postgresql://deploy:password@db.georgecloonio.local/loomio_georgecloo
nio?sslmode=require"


psql postgresql://deploy:everyoneattraction2@db.georgecloonio.local:5432/loomio_georgecloonio?sslmode=require
```
DATABASE_URL="postgresql://deploy:everyoneattraction2@db.georgecloonio.local:5432/loomio_georgecloonio?sslmode=require"
dokku config:set loomio CANONICAL_HOST="www.georgecloonio.net"
dokku config:set loomio DEFAULT_SUBDOMAIN="www"
dokku config:set loomio MIN_THREADS=1
dokku config:set loomio MAX_THREADS=1
dokku config:set loomio PUMA_WORKERS=2
dokku config:set loomio RAILS_ENV=production
dokku config:set loomio SECRET_COOKIE_TOKEN=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;`
dokku config:set loomio DEVISE_SECRET=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;`
dokku config:set loomio TLD_LENGTH=1
FORCE_SSL=1 # if you want ssl

```
ENV for plugins/optional things
```
ALLOW_ROBOTS:                1
BING_TRANSLATE_APPID:        loomio
BING_TRANSLATE_SECRET:      
AWS_ACCESS_KEY_ID:
AWS_SECRET_ACCESS_KEY:      
AWS_UPLOADS_BUCKET:          loomio-uploads
AIRBRAKE_API_KEY:           
NEW_RELIC_APP_NAME:          loomio-production
NEW_RELIC_ID:               
NEW_RELIC_LICENSE_KEY:      
NEW_RELIC_LOG:              
TAG_MANAGER_ID:              
INTERCOM_APP_API_KEY:       
INTERCOM_APP_ID:            
INTERCOM_APP_SECRET:        
OMNI_CONTACTS_GOOGLE_KEY:   
OMNI_CONTACTS_GOOGLE_SECRET:
GOOGLE_KEY:                  
GOOGLE_SECRET:               
HEAP_APP_ID:                 
FOG_DIRECTORY:               loomio-assets
FOG_HOST:                    https://loomio-uploads.s3.amazonaws.com
FOG_PROVIDER:                AWS
FACEBOOK_KEY:               
FACEBOOK_SECRET:
FB_APP_ID_META:          

```
   
### Setup DNS records
This is a good time to setup a DNS record for your VPS. [DigitalOcean](https://www.digitalocean.com/?refcode=31aac347b271) provides DNS hosting for their customers. You need to setup an A record and a Wildcard record.


* Pushing
* database setup
* ENVS 
* cronjobs for yesterday email, closing soon email, closing motions and backup

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
FAYE_URL - the url for your FAYE instance - see https://github.com/loomio/private_pub  
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
