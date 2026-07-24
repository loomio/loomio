const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');

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
