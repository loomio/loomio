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
curl --fail --remote-name https://raw.githubusercontent.com/loomio/loomio/master/deploy/forwarding.json
chmod +x create_env.sh update.sh
```

The commands below assume this is your working directory.

### Create your environment file

Create `.env` with your Loomio hostname and contact email:

```sh
./create_env.sh loomio.example.com admin@example.org
```

The script replaces every `REPLACE_WITH_...` placeholder, generates the PostgreSQL, Rails, inbound-email, and VAPID secrets, and writes `.env` with mode `0600`. It refuses to overwrite an existing `.env`.

Edit `.env` to configure your SMTP server and any optional settings you need. The template documents SSO, themes, file storage, and other optional features.

### Set up SMTP

You need to bring your own SMTP server for Loomio to send emails.

Edit the `.env` and look for the vars starting with SMTP_

You might also need to add an SPF DNS record to indicate that the SMTP can send mail for your domain.

### Forward staff email addresses

Haraka forwards configured staff addresses directly to their destination mail servers. It preserves the original `From`, `Reply-To`, subject, date, Message-ID, message body, attachments and inline images. Email-to-group and reply-by-email messages continue to go to Loomio.

The `forwarding.json` file in your deployment directory contains the rules and is mounted read-only into Haraka. It defaults to sending postmaster mail to the `SUPPORT_EMAIL` configured in `.env`:

```json
{
  "postmaster": "${SUPPORT_EMAIL}"
}
```

Use `{}` to disable forwarding. Keys can be local names or complete addresses at `REPLY_HOSTNAME`. Values are complete external email addresses, or the literal `${SUPPORT_EMAIL}`. For example, add `"contact": "staff@example.org"` to forward the contact address. Matching is exact and case-insensitive; signed Loomio reply addresses and subaddresses do not match a shorter alias. Destination addresses must be on another domain to avoid loops. Restart Haraka after editing the file:

```sh
docker compose up -d --no-deps --force-recreate haraka
```

Haraka changes only the SMTP envelope sender to `postmaster@REPLY_HOSTNAME`, so delivery failures go to the configured postmaster destination. The visible `From` and any existing `Reply-To` stay unchanged. Include a postmaster rule whenever forwarding is enabled. Operators can use `LOOMIO_MAIL_FORWARD_SENDER` to choose another monitored alias instead. Delivery reports with an empty envelope sender keep it empty to avoid bounce loops.

Direct forwarding requires outbound TCP port 25, and SPF for the envelope sender's domain must authorize this server. Mail goes directly to the destination MX, rather than through your application SMTP provider. Haraka accepts a message only after storing it in the persistent `haraka-queue` volume, and retries temporary delivery failures. A message addressed to both staff and application recipients is split at SMTP recipient acceptance: the sender retries the other recipients separately, avoiding partial delivery across the two paths.

Original DKIM signatures are retained. For messages authenticated only by SPF, configure ARC signing so the destination can inspect the authentication results from before forwarding. See [Haraka forwarding and ARC configuration](../haraka/README.md#forwarding-and-arc). ARC acceptance ultimately depends on the destination's policy.

When upgrading from application forwarding, export the existing rules before removing the old Rails path, install and verify those rules in Haraka first, and let queued `ForwardMailer.forward_message` jobs finish before deploying the application change. The legacy database table is retained for this transition and rollback; the application no longer reads it. The old `notifications` forwarding row was bypassed by Loomio's notifications-address rejection, so leave that address with Rails unless you intentionally change that policy. Staff mail handled by Haraka no longer has a copy stored in Rails Action Mailbox.

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

Instance administrators can use **Sign in as** on a user's admin page to create a one-time sign-in link. Open the link in a private browser window. These links also work when local login is disabled for an SSO-only site; users cannot request emailed sign-in links or codes on those sites.

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
