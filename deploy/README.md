# Deploy your own Loomio

These files run Loomio on a single server with Docker Compose and automatically provision TLS certificates with Let's Encrypt.

If you just want a local install of Loomio for development, see [Setting up a Loomio development environment](https://github.com/loomio/loomio/blob/master/DEVSETUP.md).

## What you'll need
* Root access to a server, on a public IP address, running Ubuntu (latest LTS release) with at least 1GB RAM.

* A domain name

* An SMTP server

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

`REPLY_HOSTNAME` must resolve to this server and ports 80, 443, and 25 must be
reachable from the internet. The deployment automatically requests a Let's
Encrypt certificate for that hostname. Haraka mounts the certificate read-only,
advertises STARTTLS when it becomes available, and reloads it after renewal.
Certificate provisioning does not interrupt inbound mail: Haraka starts without
STARTTLS while the first ACME request is pending.

Additionally, create a CNAME record for the collaborative editing server.

```
CNAME hocuspocus.loomio.example.com, loomio.example.com
```

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

Download [docker-compose.yml](docker-compose.yml), [env_template](env_template),
and [update.sh](update.sh) into the new deployment directory:

```sh
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/docker-compose.yml
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/env_template
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/update.sh
chmod +x update.sh
```

The commands below assume this is your working directory.

### Create your environment file

Copy the environment template:

```sh
cp env_template .env
chmod 600 .env
```

Generate the required secrets using the Loomio image:

```sh
docker compose run --rm --no-deps app ruby -rsecurerandom -e '%w[POSTGRES_PASSWORD DEVISE_SECRET SECRET_COOKIE_TOKEN RAILS_INBOUND_EMAIL_PASSWORD].each { |name| puts "#{name}=#{SecureRandom.hex(32)}" }'
```

Edit `.env` and replace every `REPLACE_WITH_...` placeholder. Replace the corresponding secret values with the generated output, using the same PostgreSQL password in `POSTGRES_PASSWORD` and `DATABASE_URL`. Configure your hostname, contact email, SMTP server, and any optional settings you need.

The template documents SSO, themes, file storage, and other optional features.

### Enable web push notifications

Generate one VAPID key pair for the installation:

```sh
docker compose run --rm --no-deps app bundle exec ruby -rweb-push -e 'key = WebPush.generate_key; puts "VAPID_PUBLIC_KEY=#{key.public_key}"; puts "VAPID_PRIVATE_KEY=#{key.private_key}"'
```

Add the two generated values to `.env`, then add `VAPID_SUBJECT` as a `mailto:` contact address or an HTTPS URL controlled by the installation. Web push is enabled only when `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, and `VAPID_SUBJECT` are all present. Keep the same key pair across deployments; changing it invalidates existing browser subscriptions.

### Set up SMTP

You need to bring your own SMTP server for Loomio to send emails.

If you already have an SMTP server, put its settings into `.env`.

For everyone else here are some options to consider:

- Look at the (sometimes free) services offered by [SendGrid](https://sendgrid.com/), [SparkPost](https://www.sparkpost.com/), [Mailgun](http://www.mailgun.com/), [Mailjet](https://www.mailjet.com/pricing).

- Setup your own SMTP server with something like Haraka

Edit the `.env` file and enter the right SMTP settings for your setup.

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

Confirm the settings in `.env` are correct.

After you change your `env` files you need to restart the system:

```sh
docker compose down
docker compose up -d
```

The configured Loomio image tag follows the latest patch release in its release series. To update within that series:

```sh
docker compose pull
docker compose up -d
```

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
