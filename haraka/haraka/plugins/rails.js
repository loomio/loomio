// Copied from https://github.com/mailprotector/haraka-plugin-queue-rails
// Modified by Rob Guthrie <rob@loomio.org> to use ENV vars

const http = require('http');
const https = require('https');
const { URL } = require('url');

(() => {
  const buildPluginFunction = () => {
    return function (next, connection) {
      const plugin = this;
      const { transaction, remote, hello } = connection;

      const done = (status, reason) => next(status, reason);

      const handleError = (message, reason) => {
        connection.logerror(message, plugin);
        done(DENYSOFT, reason || message);
      };

      const run = () => {
        try {
          const authString = `actionmailbox:${process.env.RAILS_INBOUND_EMAIL_PASSWORD}`;
          const authBase64 = Buffer.from(authString).toString('base64');

          const url = new URL(process.env.RAILS_INBOUND_EMAIL_URL);
          const client = url.protocol === 'https:' ? https : http;

          const options = {
            hostname: url.hostname,
            port: url.port || (url.protocol === 'https:' ? 443 : 80),
            path: url.pathname + url.search,
            method: 'POST',
            headers: {
              'Authorization': `Basic ${authBase64}`,
              'Content-Type': 'message/rfc822',
              'User-Agent': 'haraka rails docker',
            },
          };

          plugin.loginfo(`sending request to ${url.href}`);

          const req = client.request(options, (res) => {
            plugin.loginfo('request status', res.statusCode);

            // consume response so 'end' fires
            res.on('data', (chunk) => plugin.logdebug('Response chunk:', chunk.toString()));

            res.on('end', () => {
              if (res.statusCode >= 200 && res.statusCode < 300) {
                done(OK, `delivered (${res.statusCode})`);
              } else {
                done(DENYSOFT, `Rails returned ${res.statusCode}`);
              }
            });
          });

          req.on('error', (err) => {
            plugin.logerror('Request error:', err);
            done(DENYSOFT, err.message);
          });

          transaction.message_stream.pipe(req);
        } catch (err) {
          handleError(`Exception: ${err.message}`);
        }
      };

      // optional: add Haraka meta headers for traceability
      try {
        transaction.add_header('harakadata', JSON.stringify({
          mail_from: transaction.mail_from.address(),
          rcpt_to: transaction.rcpt_to.map(r => r.address()),
          remote_ip: remote.ip,
          remote_host: remote.host,
          helo: hello.host,
          uuid: transaction.uuid,
        }));
      } catch (err) {
        handleError(`Adding custom headers failed: ${err.message}`);
      }

      run();
    };
  };

  exports.load_config = function () {
    if (!process.env.RAILS_INBOUND_EMAIL_PASSWORD) this.logerror('Missing RAILS_INBOUND_EMAIL_PASSWORD');
    if (!process.env.RAILS_INBOUND_EMAIL_URL) this.logerror('Missing RAILS_INBOUND_EMAIL_URL');
  };

  exports.register = function () {
    this.register_hook('queue', 'queue_rails');
    this.load_config();
  };

  exports.queue_rails = buildPluginFunction();
})();
