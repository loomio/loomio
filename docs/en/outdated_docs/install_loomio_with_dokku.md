This document will detail how to use [Dokku Alternative](https://github.com/dokku-alt/dokku-alt) to deploy our application.

These steps assume you have [prepared a basic VPS](https://github.com/loomio/loomio/wiki/Basic-VPS-setup)
and that you have your own local [development environment](https://github.com/loomio/loomio/wiki/Setup-a-Loomio-development-environment) including git and a checkout of the Loomio code on your local computer.

The steps on this page a subset of the [Dokku Alternative](https://github.com/dokku-alt/dokku-alt) readme file, compiled together to show you the simplest way to get Loomio deployed in production mode. If you're running Loomio on a VPS for real, you're going to need to learn dokku-alt, so please [read up](https://github.com/dokku-alt/dokku-alt) on it as soon as you run into problems.

#### Setup domain name records
You need a domain name, and access to create records on it. I've written this guide using the `example.com` domain name - IE: you have your site at example.com and you want to setup Loomio at `loomio.example.com`. You'll need to replace `example.com` with your domain name for all steps of the process.

To begin with, you need to create an A record for `loomio.example.com` pointing to your VPS's ip address.

#### Install dokku-alt

SSH into your VPS as root (ie: `ssh root@loomio.example.com`) and run the following command to install Dokku Alt.
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dokku-alt/dokku-alt/master/bootstrap.sh)"
```

When the script finishes it will launch a web interface on `http://loomio.example.com:2000` for you to finalise the settings.

Open the address in your web browser:

* Paste your public key (found in `~/.ssh/id_rsa.pub`) into the text field (if you don't have a public key, you can learn how to generate one [here](https://help.github.com/articles/generating-ssh-keys/))
* Tick 'Use virtualhost naming for apps'
* Click 'Finish setup'.

#### Issuing dokku commands

dokku-alt is controlled via ssh commands from the local shell. It's easier to use if you have an alias setup.

Insert a line like the following one, into your `~/.profile` or `~/.bashrc` file.

```
alias dokku='ssh -t dokku@loomio.example.com'
```

One you've added the alias, `source` the file to use the settings in your current terminal.

```
source ~/.profile
```

Now we can use the alias! Run `dokku help` to list available commands. 

To create an empty app, type the following on your computer:

```
dokku create loomio
```

You should see:
```
-----> Application loomio created!
```

We use environment variables to configure Loomio. The following command sets the configuration needed to get started. Run this dokku command on your local machine.

```
dokku config:set loomio RACK_ENV=production \
                        RAILS_ENV=production \
                        DEVISE_SECRET=`openssl rand -base64 48` \
                        SECRET_COOKIE_TOKEN=`openssl rand -base64 48` \
                        CANONICAL_HOST=loomio.example.com \
                        TLD_LENGTH=2
```

TLD_LENGTH tells rails how many parts there are to your top level domain. For example: The hostname `loomio.example.com` has a TLD_LENGTH of 2, where as `loomio.org` has a TLD_LENGTH of 1. Just count the dots in your  loomio domain name and use that number.

#### First push

At this stage you should be able to push the app to your dokku server, but it won't work until we setup the database, from your local loomio git repo (eg: `~/projects/loomio`)

```
git remote add dokku dokku@loomio.example.com:loomio
git push dokku master
```

#### Database

You could setup your database in a number of different ways. I'll cover my preferred way to setup PostgreSQL - I'm going to assume that you want to run database and application on the same VPS.
 
Please follow the [instructions to setup PostgreSQL](https://github.com/loomio/loomio/wiki/Install-PostgreSQL) and return here when you're done.

#### Deploy and test

On your local host, from your local loomio git repo (eg: `~/projects/loomio`)

```
git push dokku master
```

Now browse to http://loomio.example.com and you should see that Loomio is running.

### Sending Email
You will need an SMTP server for sending outbound emails such as discussion notifications and group invitations.

If you don't already have an SMTP server available, you can use an SMTP service such as Sendgrid, use Gmail as an SMTP or follow our tutorial to [Run your own SMTP](https://github.com/loomio/loomio/wiki/Setup-an-SMTP-server-with-Docker)

Assuming that you have TLS setup, and authenticate against your SMTP server with a username and password, you can configure Loomio to use your SMTP server with a config command like this, but of course you'll need to replace all the values with the right ones for your situation. 

```
$ dokku config:set loomio SMTP_DOMAIN=loomio.example.com \
                          SMTP_SERVER=smtp.example.com \
                          SMTP_PORT=587 \
                          SMTP_USERNAME=loomio \
                          SMTP_PASSWORD=password
```
If your SMTP authentication system is different you should edit your `config/environments/production.rb` file to edit the settings directly.

### Scheduling cron jobs
Loomio needs to send daily summary emails, and proposal closing soon notifications at specific times. We do this with cron jobs.

Login to your docker host as root (ie: ssh root@loomio.example.com) then edit the crontab with the following command:

```
crontab -e
```

You should be able to just paste the following lines into the editor that `crontab -e` opens for you

```
# Minutes Hours Day Month Year Command
# 5 minutes past each hour send proposal closing soon notifications for proposals closing in 24 hours
5 * * * * /usr/local/bin/dokku run loomio rake loomio:send_missed_yesterday_email

# Each 15 minutes check for proposals that have expired and close them
*/15 * * * * /usr/local/bin/dokku run loomio rake loomio:close_lapsed_motions

# 1 minute past each hour, send the missed yesterday email to users in a timezone where it is 6am
1 * * * * /usr/local/bin/dokku run loomio rake loomio:send_proposal_closing_soon
```

#### Customise the in app logo

You can optionally set the in-app logo by setting an environment variable `APP_LOGO_PATH`
