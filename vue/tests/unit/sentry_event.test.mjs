import assert from 'node:assert/strict';
import test from 'node:test';

import { beforeSend } from '../../src/shared/helpers/sentry_event.mjs';

const restfulClientError = status => ({
  status,
  httpMethod: 'GET',
  httpResource: 'discussions',
  restfulClientError: true
});

const eventFor = ({ handled = false, type = 'auto.browser.global_handlers.onunhandledrejection' } = {}) => ({
  exception: {
    values: [{ mechanism: { handled, type } }]
  }
});

test('filters unhandled RestfulClient authentication rejections', () => {
  assert.equal(beforeSend(eventFor(), { originalException: restfulClientError(401) }), null);
});

test('keeps explicitly captured authorization errors with safe request tags', () => {
  const event = eventFor({ handled: true, type: 'generic' });

  const result = beforeSend(event, { originalException: restfulClientError(401) });

  assert.deepEqual(result.tags, {
    http_method: 'GET',
    http_resource: 'discussions',
    http_status: '401'
  });
  assert.deepEqual(result.fingerprint, ['restful-client', '401', 'discussions']);
});

test('keeps permission failures and unexpected errors with safe request grouping', () => {
  const event = eventFor();

  const forbidden = beforeSend(event, { originalException: restfulClientError(403) });
  assert.deepEqual(forbidden.tags, {
    http_method: 'GET',
    http_resource: 'discussions',
    http_status: '403'
  });
  assert.deepEqual(forbidden.fingerprint, ['restful-client', '403', 'discussions']);

  const serverError = beforeSend(eventFor(), { originalException: restfulClientError(500) });
  assert.deepEqual(serverError.tags, {
    http_method: 'GET',
    http_resource: 'discussions',
    http_status: '500'
  });
  assert.deepEqual(serverError.fingerprint, ['restful-client', '500', 'discussions']);
});

test('does not filter unrelated errors that happen to have an authorization status', () => {
  const event = eventFor();

  assert.equal(beforeSend(event, { originalException: { status: 401 } }), event);
});

test('does not filter network failures', () => {
  const event = eventFor();

  assert.equal(beforeSend(event, { originalException: { networkError: true } }), event);
});

test('preserves existing event tags', () => {
  const event = Object.assign(eventFor(), { tags: { environment: 'production' } });

  assert.deepEqual(beforeSend(event, { originalException: restfulClientError(500) }).tags, {
    environment: 'production',
    http_method: 'GET',
    http_resource: 'discussions',
    http_status: '500'
  });
});
