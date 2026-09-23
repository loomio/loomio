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

test('records reverse DNS results without rejecting legitimate relays', () => {
  const fcrdnsConfig = fs.readFileSync(path.join(configPath, 'fcrdns.ini'), 'utf8');

  assert.match(fcrdnsConfig, /^no_rdns\s*=\s*false$/m);
  assert.match(fcrdnsConfig, /^no_fcrdns\s*=\s*false$/m);
  assert.match(fcrdnsConfig, /^invalid_tld\s*=\s*false$/m);
  assert.match(fcrdnsConfig, /^generic_rdns\s*=\s*false$/m);
});

test('enables and reloads TLS when deployment certificates become readable', () => {
  const entrypoint = fs.readFileSync(
    path.join(__dirname, '..', 'haraka', 'docker-entrypoint.sh'),
    'utf8',
  );

  assert.match(entrypoint, /HARAKA_TLS_KEY_PATH/);
  assert.match(entrypoint, /HARAKA_TLS_CERT_PATH/);
  assert.match(entrypoint, /sed -i 's\/\^# tls\$\/tls\/'/);
  assert.match(entrypoint, /minVersion=TLSv1\.2/);
  assert.match(entrypoint, /TLS certificate files are not readable yet; starting without STARTTLS/);
  assert.match(entrypoint, /TLS certificate appeared or changed; gracefully reloading Haraka/);
  assert.match(entrypoint, /watch_tls "\$tls_fingerprint"/);
  assert.match(entrypoint, /--graceful/);
  assert.doesNotMatch(entrypoint, /TLS certificate files are not readable[^\n]+\n\s*exit 1/);
});

test('generates TLS parameters at image build time rather than SMTP startup', () => {
  const dockerfile = fs.readFileSync(path.join(__dirname, '..', 'Dockerfile'), 'utf8');

  assert.match(dockerfile, /openssl dhparam -out \/haraka\/config\/dhparams\.pem 2048/);
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
