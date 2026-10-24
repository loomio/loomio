const assert = require('node:assert/strict');
const { generateKeyPairSync } = require('node:crypto');
const { Readable } = require('node:stream');
const { test } = require('node:test');

const mailauth = require('../haraka/plugins/mailauth');
const { dkimSign } = require('mailauth/lib/dkim/sign');

const { privateKey, publicKey } = generateKeyPairSync('rsa', {
  modulusLength: 1024,
});
const privateKeyPem = privateKey.export({
  type: 'pkcs8',
  format: 'pem',
});
const publicKeyDns = publicKey.export({
  type: 'spki',
  format: 'der',
}).toString('base64');

const dnsError = () => {
  const error = new Error('DNS record not found');
  error.code = 'ENOTFOUND';
  return error;
};

const resolver = async (name, type) => {
  if (type !== 'TXT') throw dnsError();

  const records = {
    'forwarder.example': [['v=spf1 -all']],
    'partner.example': [['v=spf1 ip4:192.0.2.10 -all']],
    '_dmarc.partner.example': [['v=DMARC1; p=reject']],
    'loomio-test._domainkey.partner.example': [[`v=DKIM1; k=rsa; p=${publicKeyDns}`]],
  };

  if (!records[name]) throw dnsError();
  return records[name];
};

const authenticate = async (message, sender = 'bounce@forwarder.example') => {
  const authenticationResults = [];
  const recordedResults = [];
  const headers = {};
  const transaction = {
    message_stream: Readable.from([message]),
    notes: {},
    results: {
      add: (_plugin, result) => recordedResults.push(result),
    },
    add_leading_header: (name, value) => {
      headers[name] = value;
    },
    remove_header: () => {},
  };
  const connection = {
    transaction,
    notes: {},
    remote: { ip: '192.0.2.10' },
    local: { host: 'mx.loomio.test' },
    hello: { host: 'forwarder.example' },
    auth_results: (result) => authenticationResults.push(result),
  };
  const plugin = {
    cfg: {
      dns: { maxLookups: 10 },
      minBitLength: 1024,
    },
    resolver,
    logerror: (error) => {
      throw error;
    },
    mailauth_add_result: mailauth.mailauth_add_result,
  };

  const mailStatus = await new Promise((resolve) => {
    mailauth.hook_mail.call(
      plugin,
      (status) => resolve(status),
      connection,
      [{ get address() { return sender; } }],
    );
  });

  const dataStatus = await new Promise((resolve) => {
    mailauth.hook_data_post.call(plugin, (status) => resolve(status), connection);
  });

  return {
    authenticationResults,
    dataStatus,
    headers,
    mailStatus,
    mailauth: transaction.notes.mailauth,
    recordedResults,
  };
};

const message = [
  'From: Alice <alice@partner.example>',
  'To: group@loomio.test',
  'Subject: Authentication test',
  'Date: Thu, 24 Jul 2026 08:00:00 +0000',
  'Message-ID: <authentication-test@partner.example>',
  '',
  'Test message',
].join('\r\n');

test('reports DMARC failure without rejecting when SPF and DKIM do not authenticate From', async () => {
  const result = await authenticate(message);
  const header = result.authenticationResults.join('; ');

  assert.equal(result.mailStatus, undefined);
  assert.equal(result.dataStatus, undefined);
  assert.match(header, /\bspf=fail\b/);
  assert.match(header, /\bdmarc=fail\b/);
});

test('reports DMARC pass when aligned DKIM authenticates mail that fails SPF', async () => {
  const signed = await dkimSign(message, {
    canonicalization: 'relaxed/relaxed',
    signatureData: [{
      algorithm: 'rsa-sha256',
      signingDomain: 'partner.example',
      selector: 'loomio-test',
      privateKey: privateKeyPem,
    }],
  });
  assert.deepEqual(signed.errors, []);
  assert.match(signed.signatures, /^DKIM-Signature:/);

  const result = await authenticate(`${signed.signatures}${message}`);
  const header = result.authenticationResults.join('; ');

  assert.equal(result.mailStatus, undefined);
  assert.equal(result.dataStatus, undefined);
  assert.match(header, /\bspf=fail\b/);
  assert.match(header, /\bdkim=pass\b/);
  assert.match(header, /\bdmarc=pass\b/);
});

test('authenticates the From mailbox rather than an address inside nested comments', async () => {
  const commentedMessage = message.replace(
    'From: Alice <alice@partner.example>',
    'From: Alice (x(y) <spoof@attacker.example>) <alice@partner.example>',
  );
  const result = await authenticate(commentedMessage);

  assert.deepEqual(result.mailauth.dkim.headerFrom, ['alice@partner.example']);
  assert.equal(result.mailauth.dmarc.domain, 'partner.example');
  assert.match(result.authenticationResults.join('; '), /\bdmarc=fail\b/);
});

test('keeps an angle bracket inside a quoted local part out of the From domain', async () => {
  const quotedMessage = message.replace(
    'From: Alice <alice@partner.example>',
    'From: <"alice@attacker.example>"@partner.example>',
  );
  const result = await authenticate(quotedMessage);

  assert.deepEqual(result.mailauth.dkim.headerFrom, ['"alice@attacker.example>"@partner.example']);
  assert.equal(result.mailauth.dmarc.domain, 'partner.example');
  assert.match(result.authenticationResults.join('; '), /\bdmarc=fail\b/);
});

test('reports DMARC pass for an aligned SPF sender without DKIM', async () => {
  const result = await authenticate(message, 'bounce@partner.example');

  assert.match(result.authenticationResults.join('; '), /\bspf=pass\b/);
  assert.match(result.authenticationResults.join('; '), /\bdmarc=pass\b/);
});

test('reports authentication failure for duplicate From fields despite aligned SPF', async () => {
  const duplicateFromMessage = `From: Other <other@partner.example>\r\n${message}`;
  const result = await authenticate(duplicateFromMessage, 'bounce@partner.example');

  assert.equal(result.mailauth.dkim.fromFields, 2);
  assert.match(result.authenticationResults.join('; '), /\bdmarc=fail\b/);
  assert.doesNotMatch(result.authenticationResults.join('; '), /\bdmarc=pass\b/);
});

test('reports authentication failure for malformed From syntax despite aligned SPF', async () => {
  const malformedMessage = message.replace(
    'From: Alice <alice@partner.example>',
    'From: alice@partner.example garbage',
  );
  const result = await authenticate(malformedMessage, 'bounce@partner.example');

  assert.equal(result.mailauth.dkim.fromSyntax, 'invalid');
  assert.match(result.authenticationResults.join('; '), /\bdmarc=fail\b/);
  assert.doesNotMatch(result.authenticationResults.join('; '), /\bdmarc=pass\b/);
});
