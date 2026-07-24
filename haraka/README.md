# Haraka configured as a Rails ActionMailbox ingress

This container is all you need to receive email with your Rails app.

It listens for incoming emails on port 25 with Haraka.

It validates SPF, DKIM, and DMARC and sends those results to Loomio in a
trusted `Authentication-Results` header. Authentication failures are not
rejected at the SMTP boundary: Loomio uses the DMARC result when deciding
whether a message can be attributed to the claimed member.

It rejects messages that:

- Fail fcrdns
- Have unresolveable MAIL FROM
- Are not addressed to REPLY_HOSTNAME

It passes accepted messages to the app via `RAILS_INBOUND_EMAIL_URL`.

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
