const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { afterEach, test } = require('node:test');
const { Address } = require('@haraka/email-address');
const { createTransaction } = require('haraka/transaction');
const forward = require('../haraka/plugins/forward');

global.OK = 906;
global.DENYSOFT = 903;

afterEach(() => {
  for (const key of ['REPLY_HOSTNAME', 'SUPPORT_EMAIL', 'LOOMIO_MAIL_FORWARD_SENDER',
    'LOOMIO_MAIL_FORWARD_ARC_KEY_PATH', 'LOOMIO_MAIL_FORWARD_ARC_SELECTOR']) delete process.env[key];
});

const pluginFor = (rules = {
  'contact@loomio.example': 'contact+contact@example.net',
  'help@loomio.example': 'contact+contact@example.net',
  'postmaster@loomio.example': 'contact+postmaster@example.net',
}) => {
  process.env.REPLY_HOSTNAME = 'loomio.example';
  process.env.LOOMIO_MAIL_FORWARD_SENDER = 'postmaster@loomio.example';
  process.env.LOOMIO_MAIL_FORWARD_ARC_KEY_PATH = '/run/secrets/arc.pem';
  process.env.LOOMIO_MAIL_FORWARD_ARC_SELECTOR = 'forward';
  const plugin = {...forward, config: {get: () => rules}, register_hook: () => {}, haraka_require: () => ({})};
  forward.register.call(plugin);
  return plugin;
};

const route = (plugin, connection, address) => {
  let result;
  forward.route_recipient.call(plugin, (status, reason) => { result = {status, reason}; }, connection, [new Address(address, {postel: true})]);
  return result;
};

const transactionFor = async (message, sender = 'sender@example.com') => {
  const transaction = createTransaction('forward-test', {headers: {max_lines: 1000}});
  for (const line of message.replace(/\r?\n/g, '\r\n').match(/[^\n]*\n/g)) transaction.add_data(Buffer.from(line));
  await new Promise((resolve) => transaction.message_stream.add_line_end(resolve));
  transaction.mail_from = new Address(sender);
  transaction.rcpt_to = [new Address('contact@loomio.example')];
  transaction.notes.loomio_mail_route = 'forward';
  return transaction;
};

const readMessage = (transaction) => new Promise((resolve) => {
  transaction.message_stream.get_data({dot_stuffed: true, line_endings: '\r\n'}, resolve);
});

const queue = (plugin, transaction) => new Promise((resolve) => {
  forward.queue_forward.call(plugin, (status, reason) => resolve({status, reason}), {transaction});
});

test('matches only configured local SMTP recipients, including Bcc and case differences', () => {
  const plugin = pluginFor();
  const connection = {transaction: {notes: {}}};
  assert.equal(route(plugin, connection, 'Contact@LOOMIO.EXAMPLE').status, OK);
  assert.equal(connection.transaction.notes.loomio_mail_route, 'forward');
  const external = {transaction: {notes: {}}};
  assert.equal(route(plugin, external, 'contact@attacker.example').status, undefined);
  assert.equal(external.transaction.notes.loomio_mail_route, undefined);
  const subaddress = {transaction: {notes: {}}};
  assert.equal(route(plugin, subaddress, 'contact+u=123&k=secret@loomio.example').status, undefined);
  assert.equal(subaddress.transaction.notes.loomio_mail_route, 'rails');
});

test('defers mixed staff and group recipients in either order before any message is delivered', () => {
  const plugin = pluginFor();
  for (const addresses of [
    ['contact@loomio.example', 'group@loomio.example'],
    ['group@loomio.example', 'contact@loomio.example'],
  ]) {
    const connection = {transaction: {notes: {}}};
    assert.notEqual(route(plugin, connection, addresses[0]).status, DENYSOFT);
    assert.equal(route(plugin, connection, addresses[1]).status, DENYSOFT);
    assert.notEqual(route(plugin, connection, addresses[0]).status, DENYSOFT);
  }
});

test('queues original MIME and sender headers without copying or rebuilding attachments', async () => {
  const plugin = pluginFor();
  const message = readFileSync(join(__dirname, 'fixtures/forward-mixed.eml'), 'utf8');
  const transaction = await transactionFor(message);
  const original = await readMessage(transaction);
  transaction.rcpt_to.push(new Address('help@loomio.example'), new Address('postmaster@loomio.example'));
  let queued;
  plugin.outbound.send_trans_email = (value, next) => { queued = value; next(OK); };

  assert.equal((await queue(plugin, transaction)).status, OK);
  assert.equal(queued, transaction);
  assert.deepEqual(queued.rcpt_to.map((address) => address.address), ['contact+contact@example.net', 'contact+postmaster@example.net']);
  assert.equal(queued.mail_from.address, 'postmaster@loomio.example');
  assert.deepEqual(await readMessage(queued), original);
  assert.match(original.toString(), /From: Alice <alice@example.com>/);
  assert.match(original.toString(), /Content-Disposition: attachment/);
  assert.match(original.toString(), /Content-ID:/i);
});

test('preserves a null envelope sender on delivery reports to avoid bounce loops', async () => {
  const plugin = pluginFor();
  const transaction = await transactionFor('From: Mailer <mailer@example.net>\n\nDelivery report\n', '<>');
  plugin.outbound.send_trans_email = (value, next) => {
    assert.equal(value.mail_from.address, '');
    next(OK);
  };
  assert.equal((await queue(plugin, transaction)).status, OK);
});

test('never acknowledges staff mail until its durable queue write succeeds', async () => {
  const plugin = pluginFor();
  const transaction = await transactionFor('From: Sender <sender@example.com>\n\nHello\n');
  let complete;
  plugin.outbound.send_trans_email = (_transaction, next) => { complete = next; };
  let acknowledged = false;
  const pending = queue(plugin, transaction).then((result) => { acknowledged = true; return result; });
  assert.equal(acknowledged, false);
  complete(DENYSOFT, 'Disk full');
  assert.equal((await pending).status, DENYSOFT);
});

test('leaves application recipients with the Rails ingress', async () => {
  const plugin = pluginFor({});
  const transaction = {notes: {loomio_mail_route: 'rails'}};
  assert.equal((await queue(plugin, transaction)).status, undefined);
});

test('rejects local forwarding loops and unmonitored bounce senders at startup', () => {
  assert.throws(() => pluginFor({'contact@loomio.example': 'group@loomio.example'}), /external addresses/);
  assert.throws(() => pluginFor({'contact@loomio.example': 'staff@example.net'}), /monitored forwarding alias/);
  assert.throws(() => pluginFor({'contact@external.example': 'staff@example.net'}), /exact local addresses/);
});

test('the deployment default routes postmaster to SUPPORT_EMAIL without another required setting', () => {
  const defaults = JSON.parse(readFileSync(join(__dirname, '../../deploy/forwarding.json'), 'utf8'));
  process.env.SUPPORT_EMAIL = 'support@example.net';
  process.env.REPLY_HOSTNAME = 'loomio.example';
  const plugin = {...forward, config: {get: () => defaults}, register_hook: () => {}, haraka_require: () => ({})};
  forward.register.call(plugin);
  assert.equal(plugin.forward_rules.get('postmaster@loomio.example'), 'support@example.net');
  assert.equal(plugin.forward_sender.address, 'postmaster@loomio.example');
});
