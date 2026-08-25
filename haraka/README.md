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

It passes accepted messages to the app via `RAILS_INBOUND_EMAIL_URL`.

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

`haraka-plugin-mailauth` currently pins an older `mailauth` release. The
overrides in `package.json` keep its authentication libraries on audited
versions; the SPF/DKIM/DMARC tests cover compatibility with those overrides.

Run the Action Mailbox delivery tests with:

```sh
npm ci
npm test
```

Build the same image that CI publishes with:

```sh
docker build -t loomio/haraka-rails-docker .
```
