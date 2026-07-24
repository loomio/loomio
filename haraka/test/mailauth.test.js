const assert = require('node:assert/strict');
const { generateKeyPairSync } = require('node:crypto');
const { Readable } = require('node:stream');
const { test } = require('node:test');

const mailauth = require('haraka-plugin-mailauth');
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
    '_dmarc.partner.example': [['v=DMARC1; p=reject']],
    'loomio-test._domainkey.partner.example': [[`v=DKIM1; k=rsa; p=${publicKeyDns}`]],
  };

  if (!records[name]) throw dnsError();
  return records[name];
};

const authenticate = async (message) => {
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
      [{ address: () => 'bounce@forwarder.example' }],
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
