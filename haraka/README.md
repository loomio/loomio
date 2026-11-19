# Haraka configured as a Rails ActionMailbox ingress

This container is all you need to receive email with your Rails app.

It listens for incoming emails on port 25 with Haraka.

It validates SPF, DKIM, and DMARC and sends those results to Loomio in a
trusted `Authentication-Results` header. Authentication failures are not
rejected at the SMTP boundary: Loomio uses the DMARC result when deciding
whether a message can be attributed to the claimed member.

It also replaces any sender-supplied `harakadata` header with trusted SMTP
envelope metadata. Loomio uses the envelope recipients for routing so mail
forwarders and mailing lists do not need to rewrite the visible `To` header.
Custom relays that provide this header must remove sender-supplied copies
before stamping their own.

It records forward-confirmed reverse DNS results without rejecting solely on
PTR quality. It rejects messages that have an unresolvable MAIL FROM or are not
addressed to REPLY_HOSTNAME. Loomio then uses SPF, DKIM, DMARC, and signed reply
routes when deciding whether a received message may create content.

It passes application messages to the app via `RAILS_INBOUND_EMAIL_URL`. Configured staff aliases are delivered directly by Haraka with their original headers and MIME content.

## SMTP TLS certificates

The standard Loomio deployment requests an ACME certificate for
`REPLY_HOSTNAME` and mounts the shared nginx-proxy certificate volume read-only
in Haraka. Haraka starts without STARTTLS while the first certificate is being
issued, enables it when the files appear, and gracefully reloads after ACME
renewals change the certificate.

Custom deployments can use the same lifecycle by setting
`HARAKA_TLS_KEY_PATH` and `HARAKA_TLS_CERT_PATH` to readable PEM files. If the
variables are omitted, Haraka continues to accept SMTP without advertising
STARTTLS.

You need to set the following ENV's

- REPLY_HOSTNAME=example.com
- RAILS_INBOUND_EMAIL_PASSWORD=abc123_generate_your_own_password
- RAILS_INBOUND_EMAIL_URL=https://example.com/rails/action_mailbox/relay/inbound_emails

## Development

Haraka and its transitive dependencies are locked in `package-lock.json` and
updated by Dependabot.

`haraka-plugin-mailauth` provides configuration and result logging. The local adapter uses Mailauth's combined authentication API so message parsing and DMARC checks share the same metadata. Overrides in `package.json` select Mailauth 8 and patched Nodemailer; the authentication tests cover compatibility.

Run the Action Mailbox delivery tests with:

```sh
npm ci
npm test
```

Build the same image that CI publishes with:

```sh
docker build \
  --build-arg NODE_VERSION="$(cat ../.node-version)" \
  --build-arg NPM_VERSION="$(cat ../.npm-version)" \
  -t loomio/haraka-rails-docker .
```

## Forwarding and ARC

Forwarding rules belong to the deployment directory, in `forwarding.json`; see [the deployment guide](../deploy/README.md#forward-staff-email-addresses) and [the default rules](../deploy/forwarding.json). The image defaults to no aliases. The deployment mounts the rules file read-only at `/haraka/config/forwarding.json` and stores queued messages in the persistent `/haraka/queue` volume. Do not remove this volume while it contains mail.

The forwarding plugin accepts only explicitly configured local recipients and never enables unrestricted relaying. Staff and application recipients are separated at RCPT time. A temporary queue-write failure returns SMTP 450 so the sending server retries. After acceptance, Haraka's outbound queue retries destination failures. Failed deliveries go to a monitored envelope sender, defaulting to the postmaster alias, while original author and reply headers stay intact.

ARC signing is optional and recommended for forwarding. Mount an RSA private key read-only into the Haraka container, outside the public repository. For example, mount `./secrets/forwarding-arc.pem:/run/secrets/forwarding-arc.pem:ro` using a Compose override, and set these values in `.env`:

```dotenv
LOOMIO_MAIL_FORWARD_ARC_KEY_PATH=/run/secrets/forwarding-arc.pem
LOOMIO_MAIL_FORWARD_ARC_SELECTOR=forwarding
```

Publish the corresponding DKIM-format public key as a TXT record at `forwarding._domainkey.REPLY_HOSTNAME`. The private key remains on the server. Haraka seals the authentication results for staff mail before changing the SMTP envelope. The signing key is never copied into queued transaction notes. Verify the DNS record and destination ARC results before relying on ARC for delivery of mail without aligned DKIM. The destination decides whether to trust an ARC chain.

The existing SPF record must authorize the relay for its local envelope sender. Forwarding does not use the application's authenticated SMTP server, which may require rewriting external authors. `From`, `Reply-To`, `Date`, `Message-ID`, DKIM signatures and MIME parts are retained; normal transport trace and authentication headers are added.
