# Deploy your own Loomio

Run Loomio on a single server with Docker Compose and automatically provision TLS certificates with Let's Encrypt.

## What you'll need
- Root access to a server, on a public IP address, running Ubuntu (latest LTS release) with at least 1GB RAM.
- A domain name
- An SMTP server

## Network configuration
For this example, the hostname will be loomio.example.com and the IP address is 192.0.2.1

### DNS Records
To allow people to access the site via your hostname you need an A record:

```
A loomio.example.com, 192.0.2.1
```

Loomio supports "Reply by email" and to enable this you need an MX record so mail servers know where to direct these emails.

```
MX loomio.example.com, loomio.example.com, priority 0
```

Additionally, create a CNAME record for the collaborative editing server.

```
CNAME hocuspocus.loomio.example.com, loomio.example.com
```

### Firewall
It's up to you to configure a firewall, but Loomio needs inbound traffic on ports 25, 80 and 443

## Configure the server

### Login as root
To login to the server, open a terminal window and type:

```sh
ssh -A root@loomio.example.com
```

### Install docker

These steps to install docker are copied from [docs.docker.com](https://docs.docker.com/engine/install/ubuntu/)

```sh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Create a deployment directory

Create a directory for your Loomio configuration and persistent data:

```sh
mkdir loomio-deploy
cd loomio-deploy
```

Download the deployment files into the new directory:

```sh
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/docker-compose.yml
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/env_template
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/create_env.sh
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/update.sh
chmod +x create_env.sh update.sh
```

The commands below assume this is your working directory.

### Create your environment file

Create `.env` with your Loomio hostname and contact email:

```sh
./create_env.sh loomio.example.com admin@loomio.example.com
```

The script replaces every `REPLACE_WITH_...` placeholder, generates the PostgreSQL, Rails, inbound-email, and VAPID secrets, and writes `.env` with mode `0600`. It refuses to overwrite an existing `.env`.

Edit `.env` to configure your SMTP server and any optional settings you need. The template documents SSO, themes, file storage, and other optional features.

### Set up SMTP

You need to bring your own SMTP server for Loomio to send emails.

Edit the `.env` and look for the vars starting with SMTP_

You might also need to add an SPF DNS record to indicate that the SMTP can send mail for your domain.

### Initialize the database

This command initializes a new database for your Loomio instance to use.

```sh
docker compose up -d db
docker compose run --rm app rake db:setup
```

## Starting the services

This command starts the database, application, reply-by-email, and live-update services all at once.

```sh
docker compose up -d
```

Give it a minute to start, then visit your URL.

If you visit the url with your browser and the rails server is not yet running, but nginx is, you'll see a "503 bad gateway" error message.

You'll want to see the logs as it all starts, run the following command:

```sh
docker compose logs -f
```

## Try it out

Visit your hostname in your browser.

Once you have signed in (and confirmed your email), grant yourself admin rights

```sh
docker compose run --rm app rails runner 'User.last.update!(is_admin: true)'
```

You can now access the admin interface at https://loomio.example.com/admin.

## If something goes wrong

To see system error messages as they happen run `docker compose logs -f` and make a request against the server.

If you want to be notified of system errors you could setup [Sentry](https://sentry.io/) and add it to the env.

Read the [upgrade guide](UPGRADING.md) before changing to a newer minor or major release series.

To login to your running rails app console:

```sh
docker compose run app rails c
```

A PostgreSQL shell to inspect the database:

```sh
docker exec -ti loomio-db su - postgres -c 'psql loomio_production'
```

## Upgrading

See the [upgrade guide](UPGRADING.md) before upgrading Loomio.
