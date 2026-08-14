const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const { Address } = require('@haraka/email-address');

const configPath = path.join(__dirname, '..', 'haraka', 'config');

test('uses combined mail authentication without rejecting SPF before DKIM', () => {
  const plugins = fs.readFileSync(path.join(configPath, 'plugins'), 'utf8')
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('#'));

  assert(plugins.includes('mailauth'));
  assert(!plugins.includes('spf'));
  assert(!plugins.includes('dkim'));
});

test('explicitly cleans sender-supplied authentication results', () => {
  const connectionConfig = fs.readFileSync(path.join(configPath, 'connection.ini'), 'utf8');

  assert.match(connectionConfig, /^clean_auth_results=true$/m);
});

test('accepts legacy Loomio reply addresses with long local parts', () => {
  const connectionConfig = fs.readFileSync(path.join(configPath, 'connection.ini'), 'utf8');
  const postel = /^postel\s*=\s*true$/m.test(connectionConfig);
  const replyAddress = 'pt=c&pi=3375490&d=635548&u=570019&k=0123456789abcdef0123456789abcdef@loomio.com';
  const localPart = replyAddress.split('@')[0];

  assert.equal(Buffer.byteLength(localPart), 68);
  assert.throws(() => new Address(replyAddress), /local-part exceeds 64 octets/);
  assert.equal(new Address(replyAddress, { postel }).address, replyAddress);
});
