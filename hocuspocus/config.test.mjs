import assert from 'node:assert/strict';
import test from 'node:test';

import { authUrlFromEnv } from './config.mjs';

test('development defaults to the local application server', () => {
  assert.equal(authUrlFromEnv({}), 'http://localhost:8080/api/hocuspocus');
  assert.equal(
    authUrlFromEnv({ CANONICAL_PORT: '8181', PORT: '3100' }),
    'http://localhost:8181/api/hocuspocus',
  );
});

test('an explicit private application URL takes precedence', () => {
  assert.equal(
    authUrlFromEnv({
      PRIVATE_APP_URL: 'http://rails:3000',
      APP_URL: 'https://public.example.com',
      RAILS_ENV: 'production',
      CANONICAL_HOST: 'loomio.example.com',
    }),
    'http://rails:3000/api/hocuspocus',
  );
});

test('production uses the canonical HTTPS host', () => {
  assert.equal(
    authUrlFromEnv({ RAILS_ENV: 'production', CANONICAL_HOST: 'loomio.example.com' }),
    'https://loomio.example.com/api/hocuspocus',
  );
});

test('production rejects an absent callback host', () => {
  assert.throws(
    () => authUrlFromEnv({ RAILS_ENV: 'production' }),
    /requires PRIVATE_APP_URL/,
  );
});
