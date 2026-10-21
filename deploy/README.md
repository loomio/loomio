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

#### Email feedback and local blocks

Set `BOUNCE_ADDRESS` and `COMPLAINTS_ADDRESS` when your feedback sender addresses differ from the defaults. The feedback sender must authenticate through the trusted relay as described below.

Loomio records email delivery evidence and enforces its own suppression policy independently of the SMTP provider. Authenticated complaints and permanent bounces block the recipient address; delays, transient bounces, and unclassified bounces do not create a permanent block. Feedback with a matching original Message-ID links to the exact notification delivery. Authenticated feedback without a matching delivery can still block the reported address, without inventing a delivery link. Suppression records retain an address digest rather than the plaintext address and are not included in portable group exports.

A completed local sign-in clears Loomio blocks for the account's current email address, preserving the existing sign-in behavior. Instance administrators can also clear them from the user's admin page. Clearance retains the evidence, actor, time, and method; replaying the same delivery failure does not reinstate a cleared block. An account changing its address does not transfer an old address's block to the new address.

The SMTP provider may enforce a separate suppression list. Clearing a Loomio block does not promise that the provider will send the next email. With the optional SES integration enabled, instance administrators can use **Check SES account suppression** on a user's admin page. This read-only diagnostic needs `ses:GetSuppressedDestination` permission; it is requested only by the administrator and adds no provider calls to sending, history browsing, or sign-in. Provider lookup failures do not affect Loomio's local state. A returned entry identifies a record on the SES account suppression list; whether SES enforces it also depends on the account and configuration-set suppression settings. SES account suppression is regional and requires the exact stored address case; this check does not query Amazon's global suppression list or change any provider settings. Resolve provider blocks through the provider's own administration tools.

Feedback processing failures leave a failed Action Mailbox routing job and an unreleased received-email record. Retry the failed routing job after resolving the error. Retrying resumes the saved authenticated report; completed reports are idempotent. Include failed routing jobs and `Email feedback recipient not identified` warnings in operational monitoring so missing feedback is not overlooked. Reports without an identifiable delivery or an explicit report recipient do not create a guessed block from unrelated addresses in the report.

#### Optional Amazon SES suppression check

Set `SES_SUPPRESSION_REGION` to the sending region and give the web process AWS credentials with `ses:GetSuppressedDestination` permission through the standard AWS SDK credential chain. SMTP credentials alone cannot call the API. Omit the region variable to hide the SES diagnostic. This integration only performs an administrator-requested account suppression lookup; it does not poll message delivery, change SES suppression settings, or require Virtual Deliverability Manager, a configuration set, or a public webhook.

SES assigns its own Message-ID; Loomio saves the ID returned by the SES SMTP endpoint and the original recipient address to match forwarded feedback. Only new notification emails have these recorded identifiers. Forwarded feedback can also match the original local Message-ID when a different SMTP transport preserves it. Feedback processing requires a trusted relay's passing DKIM result for the feedback sender's domain. The bundled Haraka relay removes sender-supplied authentication headers before adding its own; relays used in its place must provide the same guarantee. Feedback that cannot be authenticated is not allowed to change delivery history or Loomio email delivery blocks.

#### Verifying feedback before a suppression-policy change

Keep SES account suppression enabled until the deployed feedback path has been verified. Send controlled notification emails through the normal SMTP path to `bounce@simulator.amazonses.com` and `complaint@simulator.amazonses.com`, using the normal sender and feedback return address. Confirm that each report arrives through the trusted relay and Action Mailbox, authenticates, links to its exact notification delivery, creates the expected local block, and prevents a subsequent send. Also verify that failed feedback processing is surfaced and can be retried without duplicate evidence. The simulator does not affect SES bounce or complaint rates; see [Amazon's simulator documentation](https://docs.aws.amazon.com/ses/latest/dg/send-an-email-from-console.html).

Before making Loomio the sole account-level suppression policy, reconcile the SES account suppression list with local blocks so provider-only historical blocks are not lost. Keep email feedback forwarding enabled and confirm that the SMTP feedback return address reaches Loomio; see [SES email feedback routing](https://docs.aws.amazon.com/ses/latest/dg/monitor-sending-activity-using-notifications-email.html). Changing the account-level policy does not disable Amazon's internal global suppression list. Treat the policy change as a separate operator action after verifying the live path and reviewing the reconciled blocks.

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

### Replacing email failure counters

Migration `20261021000002` replaces `users.bounces_count` and `users.complaints_count` with suppression records. Positive counters become legacy blocks for the account's current address, with unknown event dates and no delivery link. Counter values cannot recover the original address or notification. Stop web and job processes using the old code before migrating, then start the new version: the migration removes those columns and cannot be reversed to counters. Member-list API responses for instance administrators replace `bounces_count` and `complaints_count` with the boolean `email_delivery_blocked`. Older portable group archives can still be imported; their retired counters are ignored. It scans users twice and takes a schema lock when dropping the columns; production migration time has not been measured. Back up the database before upgrading if rollback to an older application version is required.
