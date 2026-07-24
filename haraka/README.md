# Haraka configured as a Rails ActionMailbox ingress

This container is all you need to receive email with your Rails app.

It listens for incoming emails on port 25 with Haraka.

It drops messages that
- Fail SPF
- Fail fcrdns
- Have unresolveable MAIL FROM
- TODO: validate DKIM
- Are not addressed to REPLY_HOSTNAME

And passes the rest along to your app via the RAILS_INBOUND_EMAIL_URL

You need to set the following ENV's

- REPLY_HOSTNAME=example.com
- RAILS_INBOUND_EMAIL_PASSWORD=abc123_generate_your_own_password
- RAILS_INBOUND_EMAIL_URL=https://example.com/rails/action_mailbox/relay/inbound_emails

## Development

Haraka and its transitive dependencies are locked in `package-lock.json` and
updated by Dependabot.

Run the Action Mailbox delivery tests with:

```sh
npm ci
npm test
```

Build the same image that CI publishes with:

```sh
docker build -t loomio/haraka-rails-docker .
```
