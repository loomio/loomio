const assert = require('node:assert/strict');
const http = require('node:http');
const { Readable } = require('node:stream');
const { afterEach, test } = require('node:test');

const rails = require('../haraka/plugins/rails');

global.OK = 'OK';
global.DENYSOFT = 'DENYSOFT';

const servers = [];

afterEach(async () => {
  delete process.env.RAILS_INBOUND_EMAIL_PASSWORD;
  delete process.env.RAILS_INBOUND_EMAIL_URL;
  await Promise.all(servers.splice(0).map((server) => new Promise((resolve) => server.close(resolve))));
});

const listen = async (handler) => {
  const server = http.createServer(handler);
  servers.push(server);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  return `http://127.0.0.1:${server.address().port}/rails/action_mailbox/relay/inbound_emails`;
};

const connectionFor = (message, addedHeaders = {}) => ({
  transaction: {
    message_stream: Readable.from([message]),
    mail_from: { address: () => 'sender@example.com' },
    rcpt_to: [{ address: () => 'group@loomio.example' }],
    uuid: 'message-uuid',
    add_header: (name, value) => {
      addedHeaders[name] = value;
    },
  },
  remote: {
    ip: '192.0.2.10',
    host: 'mail.example.com',
  },
  hello: {
    host: 'mail.example.com',
  },
  logerror: () => {},
});

const plugin = {
  logdebug: () => {},
  logerror: () => {},
  loginfo: () => {},
};

const deliver = (connection) => new Promise((resolve) => {
  rails.queue_rails.call(plugin, (status, reason) => resolve({ status, reason }), connection);
});

test('forwards the raw message to Action Mailbox with authentication and trace metadata', async () => {
  const password = 'inbound-secret';
  const message = [
    'From: Sender <sender@example.com>',
    'To: group@loomio.example',
    'Subject: Test message',
    '',
    'Hello from SMTP',
  ].join('\r\n');
  const addedHeaders = {};

  process.env.RAILS_INBOUND_EMAIL_PASSWORD = password;
  process.env.RAILS_INBOUND_EMAIL_URL = await listen((request, response) => {
    const body = [];
    request.on('data', (chunk) => body.push(chunk));
    request.on('end', () => {
      assert.equal(request.method, 'POST');
      assert.equal(request.headers.authorization, `Basic ${Buffer.from(`actionmailbox:${password}`).toString('base64')}`);
      assert.equal(request.headers['content-type'], 'message/rfc822');
      assert.equal(Buffer.concat(body).toString(), message);
      response.writeHead(204);
      response.end();
    });
  });

  const result = await deliver(connectionFor(message, addedHeaders));

  assert.equal(result.status, OK);
  assert.match(result.reason, /delivered \(204\)/);
  assert.deepEqual(JSON.parse(addedHeaders.harakadata), {
    mail_from: 'sender@example.com',
    rcpt_to: ['group@loomio.example'],
    remote_ip: '192.0.2.10',
    remote_host: 'mail.example.com',
    helo: 'mail.example.com',
    uuid: 'message-uuid',
  });
});

test('soft-denies delivery when Action Mailbox returns an error', async () => {
  process.env.RAILS_INBOUND_EMAIL_PASSWORD = 'inbound-secret';
  process.env.RAILS_INBOUND_EMAIL_URL = await listen((_request, response) => {
    response.writeHead(503);
    response.end();
  });

  const result = await deliver(connectionFor('Subject: Test\r\n\r\nMessage'));

  assert.equal(result.status, DENYSOFT);
  assert.equal(result.reason, 'Rails returned 503');
});
